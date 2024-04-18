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
class EEGRecordingSession { // swiftlint:disable:this type_body_length
    #if targetEnvironment(simulator)
    static let recordingDuration: TimeInterval = 15
    #else
    static let recordingDuration: TimeInterval = 2 * 60
    #endif

    /// Determines how received samples are updated in the UI.
    private static let uiProcessingType: ProcessingType = .downsample(targetSampleRate: 24)

    private let logger = Logger(subsystem: "edu.stanford.names", category: "EEGRecordingSession")

    /// The recording id.
    let id: UUID
    let patientId: String

    let measurements: [VisualizedSignal]
    /// The amount of total recorded samples.
    @MainActor private(set) var totalSamples = 0

    private let fileWriter: BDFFileWriter
    private let sampleSource: AsyncStream<CombinedEEGSample>

    /// Array of buffered channels before they get handed of to the BDF file writer.
    @EEGProcessing private var bufferedChannels: [BufferedChannel<BDFSample>]
    /// Array of buffered channels before they get moved to the main thread for a UI update (e.g., downsampled or batched processing).
    @EEGProcessing private var uiBufferedChannels: [BufferedChannel<BDFSample>]

    @MainActor var recordingState: RecordingState = .preparing
    @EEGProcessing private var shouldAcceptSamples = false

    /// The task that consumes new samples from the `sampleSource` stream.
    @MainActor @ObservationIgnored private var recordingTask: Task<Void, Never>? {
        willSet {
            recordingTask?.cancel()
        }
    }

    /// The timer that counts down the recording.
    @MainActor @ObservationIgnored private var recordingTimer: Timer? {
        willSet {
            recordingTimer?.invalidate()
        }
    }

    var startDate: Date {
        guard case let .structured(recording) = fileWriter.fileInformation.recording else {
            preconditionFailure("Unexpected non-structured recording format!")
        }

        return recording.startDate
    }


    private var completedTask: CompletedTask {
        CompletedTask(taskId: MeasurementTask.eegMeasurement.id, content: .eegRecording(recordingId: id))
    }

    @EEGProcessing
    init(id: UUID, url: URL, patient: Patient, device: ConnectedDevice, investigatorCode: String?, stream: AsyncStream<CombinedEEGSample>) throws {
        guard let patientId = patient.id else {
            logger.error("Patient didn't have a valid patient id. Received: \(String(describing: patient))")
            throw EEGRecordingError.unexpectedErrorStart
        }

        self.id = id
        self.patientId = patientId
        self.sampleSource = stream

        let patientInformation = PatientInformation(from: patient)
        let recordingInformation = RecordingInformation(
            startDate: .now, // we will patch it later on
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
            throw EEGRecordingError.unexpectedErrorStart
        }

        let visualizedSignals = signals.map { signal in
            // we always set recordDuration to be an int
            let sampleRate = signal.sampleCount / Int(fileInformation.recordDuration)
            let batching = BatchingConfiguration(from: Self.uiProcessingType, sourceSampleRate: sampleRate)
            return VisualizedSignal(label: signal.label, sourceSampleRate: sampleRate, batching: batching)
        }

        self.bufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)
        self.uiBufferedChannels = .init(repeating: BufferedChannel(), count: signals.count)

        self.measurements = visualizedSignals

        logger.debug(
            """
            Starting recording session with the following configuration:
            id: \(id)
            patientId: \(patientId)
            patientInformation: \(String(describing: patientInformation))
            recordingInformation: \(String(describing: recordingInformation))
            fileInformation: \(String(describing: fileInformation))
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
    func runRecording() async {
        let startDate: Date = .now
        recordingState = .inProgress(duration: startDate...startDate.addingTimeInterval(Self.recordingDuration))

        await EEGProcessing.run {
            updateStartDate(to: startDate)
        }

        let task = Task { @EEGProcessing in
            // Either this task will be cancelled or the async stream finished.
            // In both cases the bluetooth transmission will be stopped.
            for await sample in sampleSource {
                append(sample)
            }
        }
        recordingTask = task // only used to cancel, in the case of an internal error

        // timer for the recording, on completion will cancel the task
        recordingTimer = Timer.scheduledTimer(withTimeInterval: EEGRecordingSession.recordingDuration, repeats: false) { [weak self] _ in
            // calling saveRecording will be handled by the caller of this method!
            task.cancel()
            self?.logger.debug("EEG recording session completed!")
        }

        let logger = logger
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel() // cancels the producer stream and stops recording
            logger.debug("Received cancellation for ongoing recording session ...")
        }

        self.recordingTimer = nil
        self.recordingTask = nil

        // ensure that we are cleaning up our resources if we are cancelled from the outside!
        if Task.isCancelled {
            Task { @EEGProcessing in
                handleCancellation()
            }
        }
    }

    @MainActor
    func saveRecording(standard: NAMSStandard, patientList: PatientListModel, connectedDevice: ConnectedDevice?) async {
        recordingState = .saving

        await _saveRecording(standard: standard, patientList: patientList, connectedDevice: connectedDevice)
    }

    @MainActor
    func retryFileUpload(standard: NAMSStandard, patientList: PatientListModel) async {
        switch recordingState {
        case .fileUploadFailed:
            recordingState = await tryFileUpload(to: standard, using: patientList)
        case .taskUploadFailed:
            recordingState = await tryTaskUpload(patientList: patientList)
        default:
            break
        }
    }

    @EEGProcessing
    private func _saveRecording(standard: NAMSStandard, patientList: PatientListModel, connectedDevice: ConnectedDevice?) async {
        tryClosingFileWriter()

        // We just ignore the buffered samples for now.
        // A data record has a size of 1 second (typically) so we don't loose out on too much.

        let resultingState = await tryFileUpload(to: standard, using: patientList)

        await MainActor.run {
            recordingState = resultingState
        }
    }

    @EEGProcessing
    private func tryFileUpload(to standard: NAMSStandard, using patientList: PatientListModel) async -> RecordingState {
        if let url = EEGRecordings.tempRecordingFileURL(id: id) {
            do {
                try await standard.uploadEEGRecording(file: url, recordingId: id, patientId: patientId, format: .bdf)

                tryRemovingTempFile() // only remove upon a successful upload
            } catch {
                logger.error("Failed to upload eeg recording: \(error)")
                return .fileUploadFailed(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to upload EEG recording."))
            }
        } else {
            // this is an erroneous state we can't recover from. File just doesn't exist for some reason.
            logger.error("Failed to upload EEG recording. File doesn't exists at \(EEGRecordings.tempFileUrl(id: self.id))")
            return .unrecoverableError(EEGRecordingError.unrecoverableErrorSaving)
        }

        return await tryTaskUpload(patientList: patientList)
    }

    @EEGProcessing
    private func tryTaskUpload(patientList: PatientListModel) async -> RecordingState {
        do {
            try await patientList.add(task: completedTask)
        } catch {
            return .taskUploadFailed((AnyLocalizedError(error: error, defaultErrorDescription: "Failed to mark task as completed")))
        }
        return .completed
    }

    @EEGProcessing
    private func updateStartDate(to date: Date) {
        let current = fileWriter.fileInformation
        guard case let .structured(recording) = current.recording else {
            preconditionFailure("EDF Files must use structured recording information.")
        }

        let updated = RecordingInformation(
            startDate: date,
            code: recording.code,
            investigatorCode: recording.investigatorCode,
            equipmentCode: recording.equipmentCode
        )

        fileWriter.updateFileInformation(.init(subject: current.subject, recording: .structured(updated), recordDuration: current.recordDuration))
    }

    @EEGProcessing
    private func handleCancellation() {
        tryClosingFileWriter()
        tryRemovingTempFile()
    }

    @EEGProcessing
    private func tryClosingFileWriter() {
        shouldAcceptSamples = false

        do {
            try fileWriter.close()
        } catch {
            logger.error("Failed to close file writer of recording session: \(error)")
        }
    }

    @EEGProcessing
    private func tryRemovingTempFile() {
        do {
            try EEGRecordings.removeTempRecordingFile(id: id)
        } catch {
            logger.error("Failed to remove temporary file storage: \(error)")
        }
    }


    @EEGProcessing
    private func append(_ sample: CombinedEEGSample) {
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
        var addedSamples = 0 // track the amount of added samples for a total count!

        let first = measurements.startIndex
        for (index, signal) in zip(measurements.indices, measurements) {
            let sample = sample.channels[index]

            guard let batching = signal.batching else {
                samples.append((index, sample)) // just forward if there is no batching enabled
                
                if index == first {
                    addedSamples += 1
                }
                continue
            }

            // buffer incoming sample for batching
            uiBufferedChannels[index].append(sample)

            guard uiBufferedChannels[index].hasBuffered(count: batching.samplesToCombine) else {
                continue // not enough samples in the buffer yet
            }

            let batchingCandidates = uiBufferedChannels[index].pop(count: batching.samplesToCombine)
            
            if index == first {
                addedSamples += batching.samplesToCombine
            }

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
        let finalAddedSamples = addedSamples
        await MainActor.run {
            totalSamples += finalAddedSamples
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
            await EEGProcessing.run {
                // we just prevent more sample to arrive
                shouldAcceptSamples = false
            }

            await MainActor.run {
                recordingState = .unrecoverableError(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "Failed to save eeg measurements."
                ))

                recordingTask?.cancel() // cancel the recording.
            }
        }
    }
}
