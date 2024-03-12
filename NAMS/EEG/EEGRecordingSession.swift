//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


/// A single sample combining the value of all channels.
struct CombinedEEGSample {
    /// The list of samples for all channels.
    ///
    /// Channels are referred by the index. The order must be the same as the provided `Signal` description.
    let channels: [BDFSample]


    init(channels: [BDFSample]) {
        self.channels = channels
    }
}

struct TimedSample<S: Sample> {
    let time: TimeInterval
    private let sample: S

    var value: S.Value {
        sample.value
    }

    init(time: TimeInterval, sample: S) {
        self.time = time
        self.sample = sample
    }
}


extension TimedSample: Hashable {
    static func == (lhs: TimedSample, rhs: TimedSample) -> Bool {
        lhs.sample == rhs.sample
    }

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sample)
    }
}


struct VisualizedSignal {
    let label: SignalLabel
    let sampleRate: Int
    let sampleOffset: Int

    fileprivate(set) var samples: [BDFSample]

    var timedSamples: [TimedSample<BDFSample>] {
        samples.enumerated().reduce(into: []) { result, enumerated in
            result.append(TimedSample(time: time(forSample: enumerated.offset), sample: enumerated.element))
        }
    }


    var lowerBound: TimeInterval {
        time(forSample: 0)
    }

    init(label: SignalLabel, sampleRate: Int, sampleOffset: Int = 0, samples: [BDFSample]) {
        // swiftlint:disable:previous function_default_parameter_at_end
        self.label = label
        self.sampleRate = sampleRate
        self.sampleOffset = sampleOffset
        self.samples = samples
    }

    init(copy signal: VisualizedSignal, suffix: TimeInterval) {
        let suffixCount = Int(suffix * Double(signal.sampleRate))

        self.label = signal.label
        self.sampleRate = signal.sampleRate
        self.sampleOffset = signal.sampleOffset + max(0, signal.samples.count - suffixCount)

        self.samples = signal.samples.suffix(suffixCount)
    }


    private func time(forSample offset: Int) -> TimeInterval {
        // we calculate time with SAMPLE_COUNT/SAMPLE_RATE
        Double(sampleOffset + offset) / Double(sampleRate)
    }
}


@Observable
class EEGRecordingSession {
    private var fileWriter: BDFFileWriter
    // TODO: can this be EEGProcessing isolated?
    private var bufferedChannels: [Channel<BDFSample>]


    private var _measurements: [VisualizedSignal] = []
    private(set) var startDate: Date // TODO: MainActor?

    @MainActor var measurements: [VisualizedSignal] {
        _measurements
    }


    init(id: UUID, url: URL, patient: Patient, device: ConnectedDevice, investigatorCode: String?) throws {
        let startDate = Date.now // TODO: the device might want to update that!>

        let patientInformation = PatientInformation(from: patient)
        let recordingInformation = RecordingInformation(
            startDate: startDate,
            code: "\(id.uuidString.prefix(8))",
            investigatorCode: investigatorCode.map { String($0.prefix(30)) },
            equipmentCode: device.equipmentCode + "@NN" // e.g., SML_BIO_127@NN, MUSE_2_E7E9@NN
        )

        let fileInformation = FileInformation(
            subject: .structured(patientInformation),
            recording: .structured(recordingInformation),
            recordDuration: device.recordDuration // TODO: that's all the same anyways?
        )

        guard let signals = device.signalDescription else {
            throw EEGRecordingError.deviceNotReady
        }

        // TODO: always continuous recording right? (only if we want to support BDF+?) => then we need bdf+/edf+ annotations
        self.fileWriter = try BDFFileWriter(url: url, information: fileInformation, signals: signals)
        // TODO: map above error to something localizable!

        self.bufferedChannels = Array(repeating: Channel(samples: []), count: signals.count)
        self.startDate = startDate

        self._measurements = signals.map { signal in
            let sampleRate = signal.sampleCount / fileInformation.recordDuration
            return VisualizedSignal(label: signal.label, sampleRate: sampleRate, samples: [])
        }
    }

    @MainActor
    func livePreview(interval: TimeInterval) -> [VisualizedSignal] {
        measurements.map {
            VisualizedSignal(copy: $0, suffix: interval)
        }
    }


    @EEGProcessing
    func append(_ sample: CombinedEEGSample) {
        guard sample.channels.count == fileWriter.signals.count else {
            // TODO: log this error?
            /*
             logger.error("""
             Failed to process data acquisition \(acquisition.totalSampleCount). \
             Received \(weirdCounts) samples that didn't have the expected channel count of \(deviceConfiguration.channelCount)
             """)
             */
            return
        }

        // ensure we are consistent!
        assert(fileWriter.signals.count == bufferedChannels.count, "") // TODO: update message

        for (index, bdfSample) in zip(sample.channels.indices, sample.channels) {
            // TODO: create a new type so this is easier and nicer? and reuses memory?
            var channel = Channel(samples: bufferedChannels[index].samples + [bdfSample])
            bufferedChannels[index] = channel
        }

        flushToDisk()

        Task { @MainActor in
            assert(sample.channels.count == measurements.count) // TODO: message!


            // TODO: downsample visualized signals!
            for (index, bdfSample) in zip(sample.channels.indices, sample.channels) {
                _measurements[index].samples.append(bdfSample)
            }
        }
    }

    @EEGProcessing
    private func flushToDisk() {
        var channels: [Channel<BDFSample>] = []
        channels.reserveCapacity(fileWriter.signals.count)

        // TODO: check if we can write a chunk to the file!
        for (index, signal) in zip(fileWriter.signals.indices, fileWriter.signals) {
            let channel = bufferedChannels[index]
            if channel.samples.count < signal.sampleCount {
                // if there is a single channel not having enough samples, we do not write anything, just return
                return
            }

            // TODO: take n samples; add to list of channels!
        }

        return // TODO: IMPLEMENT!

        let finalChannels = channels
        let fileWriter = fileWriter
        Task.detached {
            // TODO: make sure this happens in serial + handle errors?
            try fileWriter.addRecord(DataRecord(channels: finalChannels))
        }
    }
}
