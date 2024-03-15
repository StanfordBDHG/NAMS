//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation
import OSLog


@globalActor
private actor EEGFileStorage {
    static let shared = EEGFileStorage()
}


@Observable
class EEGRecordingSession {
    private static let recordingDuration = 2*60 // TODO: currently 2 minutes, 2 min 3 sec

    private let logger = Logger(subsystem: "edu.stanford.names", category: "EEGRecordingSession")

    /// The recording id.
    let id: UUID
    private var _startDate: Date

    // these two are effectively isolated to @EEGProcessing
    private var fileWriter: BDFFileWriter
    private var bufferedChannels: [BufferedChannel<BDFSample>]


    private var _measurements: [VisualizedSignal] = []

    @MainActor var measurements: [VisualizedSignal] {
        _measurements
    }

    @MainActor var startDate: Date {
        _startDate
    }

    @MainActor var remainingSeconds: Int {
        20
    }

    init(id: UUID, url: URL, patient: Patient, device: ConnectedDevice, investigatorCode: String?) throws {
        self.id = id
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
            recordDuration: device.recordDuration
        )

        let signals = try device.signalDescription

        // TODO: always continuous recording right? (only if we want to support BDF+?) => then we need bdf+/edf+ annotations
        do {
            self.fileWriter = try BDFFileWriter(url: url, information: fileInformation, signals: signals)
        } catch {
            logger.error("Failed to create BDFFileWriter at \(url.path): \(error)")
            throw EEGRecordingError.unexpectedError
        }

        self.bufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)

        self._startDate = startDate
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
            logger.error("""
                         EEG Device provided sample with \(sample.channels.count) channels, \
                         however signal description specified \(self.fileWriter.signals.count). Ignoring sample ...
                         """)
            return
        }

        // ensure we are consistent!
        precondition(
            fileWriter.signals.count == bufferedChannels.count,
            "Local channel buffer of size \(bufferedChannels.count) doesn't match expected signal count of \(sample.channels.count)"
        )

        for (index, bdfSample) in zip(sample.channels.indices, sample.channels) {
            bufferedChannels[index].append(bdfSample)
        }

        flushToDisk()

        Task { @MainActor in
            precondition(
                sample.channels.count == measurements.count,
                "Buffer of visualized samples of size \(measurements.count) doesn't match expected signal count of \(sample.channels.count)"
            )


            // TODO: downsample visualized signals!
            for (index, bdfSample) in zip(sample.channels.indices, sample.channels) {
                _measurements[index].samples.append(bdfSample)
            }
        }
    }

    @EEGProcessing
    private func flushToDisk() {
        // check if all buffered channels have enough signals to produce a data record
        for (index, signal) in zip(fileWriter.signals.indices, fileWriter.signals) {
            let channel = bufferedChannels[index]
            if !channel.hasBuffered(count: signal.sampleCount) {
                // if there is a single channel not having enough samples, we do not write anything, just return
                return
            }
        }

        // create the channels array
        var channels: [Channel<BDFSample>] = []
        channels.reserveCapacity(fileWriter.signals.count)

        for (index, signal) in zip(fileWriter.signals.indices, fileWriter.signals) {
            let channel = bufferedChannels[index].pop(count: signal.sampleCount)
            channels.append(channel)
        }

        /// Create and store a new data record.
        let record = DataRecord(channels: channels)
        let fileWriter = fileWriter
        Task { @EEGFileStorage in
            try fileWriter.addRecord(record)
        }
    }
}
