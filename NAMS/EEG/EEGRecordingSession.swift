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

    /// Determines how received samples are updated in the UI.
    private static let uiProcessingType: ProcessingType = .batched(batchRate: 24)

    private let logger = Logger(subsystem: "edu.stanford.names", category: "EEGRecordingSession")

    /// The recording id.
    let id: UUID
    let patientId: String

    @MainActor private(set) var startDate: Date
    let measurements: [VisualizedSignal]

    private let fileWriter: BDFFileWriter

    // TODO: make intervals specific to the device type!
    // TODO: clip recordings in chart

    @EEGProcessing private var bufferedChannels: [BufferedChannel<BDFSample>]
    @EEGProcessing private var uiBufferedChannels: [BufferedChannel<BDFSample>]
    /// Mirrors the recording state, but is synched to a different thread.
    @EEGProcessing private var shouldAcceptSamples = false


    // TODO: set!
    @MainActor var recordingState: RecordingState = .preparing

    @EEGProcessing
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
            let sampleRate = signal.sampleCount / Int(fileInformation.recordDuration) // TODO: review conversion to Int (builds upon assumptions)
            let batching = BatchingConfiguration(from: Self.uiProcessingType, sourceSampleRate: sampleRate)
            return VisualizedSignal(label: signal.label, sourceSampleRate: sampleRate, batching: batching)
        }

        self.bufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)
        self.uiBufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)

        self._startDate = startDate
        self.measurements = visualizedSignals

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

    @MainActor
    func startRecordingCountdown() async {
        // TODO: toggle (should collect samples") => requires start date modification?
        recordingState = .inProgress

        await EEGProcessing.run {
            shouldAcceptSamples = true
            // TODO: this should be the new start date?
        }
    }

    @MainActor
    func saveRecording(standard: NAMSStandard, connectedDevice: ConnectedDevice?) async {
        // TODO: should we verify that we are in a given state?
        recordingState = .saving

        await _saveRecording(standard: standard, connectedDevice: connectedDevice)
    }

    @MainActor
    func retryFileUpload(standard: NAMSStandard) async {
        guard case .fileUploadFailed = recordingState else {
            return // TODO: anything else we can try?
        }
        // TODO guard fileUploadFailed state

        recordingState = await tryFileUpload(to: standard)
    }

    @MainActor
    func cancelRecording() async { // TODO: make this non-throwing?
        do {
            try await closeWriter()
        } catch {
            logger.error("Failed to close file writer of recording session: \(error)")
        }

        do {
            // TODO: upload to firebase?
            try await EEGRecordings.removeTempRecordingFile(id: id)
        } catch {
            logger.error("Failed to remove temporary file storage: \(error)")
        }
    }

    @EEGProcessing
    private func _saveRecording(standard: NAMSStandard, connectedDevice: ConnectedDevice?) async {
        do {
            try closeWriter() // TODO: make closeWriter always non-throwing?
        } catch {
            logger.error("Failed to close file writer of recording session: \(error)")
        }

        async let stopRecordingTask: Void? = connectedDevice?.stopRecording()

        let resultingState = await tryFileUpload(to: standard)

        do {
            try await stopRecordingTask
        } catch {
            logger.error("Failed to stop sample collection on bluetooth device: \(error)")
        }

        await MainActor.run {
            recordingState = resultingState
        }
    }

    @EEGProcessing
    private func tryFileUpload(to standard: NAMSStandard) async -> RecordingState {
        // TODO: rename function!
        let resultingState: RecordingState

        if let url = EEGRecordings.tempRecordingFileURL(id: id) {
            do {
                try await standard.uploadEEGRecording(file: url, recordingId: id, patientId: patientId, format: .bdf)
                resultingState = .completed
            } catch {
                logger.error("Failed to upload eeg recording: \(error)")
                // TODO: default error?
                resultingState = .fileUploadFailed(AnyLocalizedError(error: error))
            }

            // file will be removed at a later point in time, cancelRecording is always called // TODO: should we do it like that?
        } else {
            // this is an erroneous state we can't recover from. File just doesn't exist for some reason.
            // TODO: replace error with something that explain issue!
            resultingState = .unrecoverableError(AnyLocalizedError(error: CancellationError()))
        }

        return resultingState
    }

    @EEGProcessing
    private func closeWriter() throws {
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
            sample.channels.count == measurements.count,
            "Buffer of visualized samples of size \(measurements.count) doesn't match expected signal count of \(sample.channels.count)"
        )
        precondition(
            sample.channels.count == uiBufferedChannels.count,
            "Local channel buffer of size \(uiBufferedChannels.count) doesn't match expected signal count of \(sample.channels.count)"
        )

        // collect all samples that should be posted
        var samples: [(index: Int, sample: BDFSample)] = []

        for (index, signal) in zip(measurements.indices, measurements) {
            let sample = sample.channels[index]

            guard let batching = signal.batching else {
                samples.append((index, sample)) // just forward if there is no batching enabled
                continue
            }

            // buffer incoming sample for batching
            uiBufferedChannels[index].append(sample)

            guard uiBufferedChannels[index].hasBuffered(count: batching.samplesToCombine) else {
                continue // not enough samples in the buffer yet
            }

            let batchingCandidates = uiBufferedChannels[index].pop(count: batching.samplesToCombine)

            switch batching.action {
            case .none:
                // batching with no action just dispatches multiple samples within one UI update
                samples.append(contentsOf: batchingCandidates.samples.map { (index, $0) })
            case .downsample:
                // downsampling uses a simple averaging approach ...
                let totalValue: Int32 = batchingCandidates.samples.reduce(into: 0) { partialResult, sample in
                    partialResult += sample.value
                }

                // ... resulting in a single sample.
                let downsamplesSample = BDFSample(totalValue / Int32(batchingCandidates.samples.count))
                samples.append((index, downsamplesSample))
            }
        }

        guard !samples.isEmpty else {
            return
        }

        let finalSamples = samples
        await MainActor.run {
            for (index, sample) in finalSamples {
                measurements[index].samples.append(sample)
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

        await addRecord(record: record)
    }

    @EEGFileStorage
    private func addRecord(record: DataRecord<BDFSample>) async {
        do {
            // addRecord should only be called on the dedicated @EEGFileStorage actor to keep the @EEGProcessing actor free.
            try fileWriter.addRecord(record)
        } catch {
            logger.error("Failed to add recording to file writer: \(error)")
            await MainActor.run {
                // TODO: how to handle that? just cancel the recording?
                // TODO: would need to disconnect from device! (or just rely on being done eventually through onDisappear?)
                recordingState = .unrecoverableError(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "Failed to save eeg measurements."
                ))
            }
        }
    }
}
