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
import SpeziViews


@globalActor
private actor EEGFileStorage {
    static let shared = EEGFileStorage()
}


@Observable
class EEGRecordingSession {
    #if targetEnvironment(simulator)
    static let recordingDuration: TimeInterval = 30
    #else
    static let recordingDuration: TimeInterval = 2 * 60
    #endif

    /// The sample rate we are targeting for the live preview.
    static let uiTargetSampleRate = 32

    private let logger = Logger(subsystem: "edu.stanford.names", category: "EEGRecordingSession")

    /// The recording id.
    let id: UUID
    let patientId: String

    // these two are effectively isolated to @MainActor
    private var _startDate: Date
    private let _measurements: [VisualizedSignal]
    private var uiBufferedChannels: [BufferedChannel<BDFSample>]

    // these two are effectively isolated to @EEGProcessing
    private var fileWriter: BDFFileWriter
    private var bufferedChannels: [BufferedChannel<BDFSample>]
    @EEGProcessing private var shouldAcceptSamples = true


    @MainActor var viewState: ViewState = .idle // TODO: actually use for processes?

    @MainActor var measurements: [VisualizedSignal] {
        _measurements
    }

    @MainActor var startDate: Date {
        _startDate
    }

    init(id: UUID, url: URL, patient: Patient, device: ConnectedDevice, investigatorCode: String?) throws {
        guard let patientId = patient.id else {
            logger.error("Patient didn't have a valid patient id. Received: \(String(describing: patient))")
            throw EEGRecordingError.unexpectedError
        }

        self.id = id
        self.patientId = patientId

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

        do {
            let writer = try BDFFileWriter(url: url, information: fileInformation, signals: signals)
            try writer.writeHeader()
            self.fileWriter = writer
        } catch {
            logger.error("Failed to create BDFFileWriter at \(url.path): \(error)")
            throw EEGRecordingError.unexpectedError
        }

        let visualizedSignals = signals.map { signal in
            let sampleRate = signal.sampleCount / fileInformation.recordDuration
            let downsampling = DownsampleConfiguration(targetSampleRate: Self.uiTargetSampleRate, sourceSampleRate: sampleRate)
            return VisualizedSignal(label: signal.label, sourceSampleRate: sampleRate, downsampling: downsampling)
        }

        self.bufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)
        self.uiBufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)

        self._startDate = startDate
        self._measurements = visualizedSignals

        logger.debug(
            """
            Starting recording session with the following configuration:
            id: \(id)
            patientId: \(patientId)
            patientInformation: \(String(describing: patientInformation))
            recordingInformation: \(String(describing: recordingInformation))
            fileInformation: \(String(describing: fileInformation))
            signals: \(String(describing: signals))
            visualizedSignals: \(String(describing: visualizedSignals))
            """
        )
    }

    @MainActor
    func livePreview(interval: TimeInterval) -> [VisualizedSignal] {
        measurements.map {
            VisualizedSignal(copy: $0, suffix: interval)
        }
    }

    @EEGProcessing
    func close() throws {
        shouldAcceptSamples = false

        // We just ignore the buffered samples for now.
        // A data record has a size of 1 second (typically) so we don't loose out on too much.

        try fileWriter.close() // TODO: rewrite the file header?
    }


    @EEGProcessing
    func append(_ sample: CombinedEEGSample) {
        guard shouldAcceptSamples else {
            return
        }

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

        Task {
            async let flushHandle: Void = flushToDisk()
            async let sampleHandle: Void = processSamplesForUI(sample)

            _ = await (flushHandle, sampleHandle)
        }
    }

    @EEGProcessing
    private func processSamplesForUI(_ sample: CombinedEEGSample) async {
        precondition(
            sample.channels.count == _measurements.count,
            "Buffer of visualized samples of size \(_measurements.count) doesn't match expected signal count of \(sample.channels.count)"
        )
        precondition(
            sample.channels.count == uiBufferedChannels.count,
            "Local channel buffer of size \(uiBufferedChannels.count) doesn't match expected signal count of \(sample.channels.count)"
        )

        // collect all samples that should be posted
        var samples: [(index: Int, sample: BDFSample)] = []

        for (index, signal) in zip(_measurements.indices, _measurements) {
            let sample = sample.channels[index]

            guard let downsampling = signal.downsampling else {
                samples.append((index, sample)) // just forward if there is no downsampling
                continue
            }

            // buffer incoming sample for downsampling
            uiBufferedChannels[index].append(sample)

            guard uiBufferedChannels[index].hasBuffered(count: downsampling.samplesToCombine) else {
                continue // not enough samples in the buffer yet
            }

            let downsamplingCandidates = uiBufferedChannels[index].pop(count: downsampling.samplesToCombine)
            let totalValue: Int32 = downsamplingCandidates.samples.reduce(into: 0) { partialResult, sample in
                partialResult += sample.value
            }

            let downsamplesSample = BDFSample(totalValue / Int32(downsamplingCandidates.samples.count))
            samples.append((index, downsamplesSample))
        }

        guard !samples.isEmpty else {
            return
        }

        let finalSamples = samples
        await MainActor.run {
            for (index, sample) in finalSamples {
                _measurements[index].samples.append(sample)
            }
        }
    }

    @EEGProcessing
    private func flushToDisk() async {
        // check if all buffered channels have enough signals to produce a data record
        for (index, signal) in zip(fileWriter.signals.indices, fileWriter.signals) {
            let channel = bufferedChannels[index]

            guard channel.hasBuffered(count: signal.sampleCount) else {
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

        await addRecord(to: fileWriter, record: record)
    }

    @EEGFileStorage
    private func addRecord(to writer: BDFFileWriter, record: DataRecord<BDFSample>) async {
        do {
            try fileWriter.addRecord(record)
        } catch {
            logger.error("Failed to add recording to file writer: \(error)")
            await MainActor.run {
                // TODO: how to handle that? just cancel the recording?
                viewState = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "Failed to save eeg measurements."
                ))
            }
        }
    }
}
