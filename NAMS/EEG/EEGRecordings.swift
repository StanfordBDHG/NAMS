//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi
import SpeziAccount


@Observable
class EEGRecordings: Module, EnvironmentAccessible, DefaultInitializable {
    private static let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

    @StandardActor @ObservationIgnored private var standard: NAMSStandard

    @Dependency @ObservationIgnored private var deviceCoordinator: DeviceCoordinator
    @Dependency @ObservationIgnored private var patientList: PatientListModel

    @MainActor private(set) var recordingSession: EEGRecordingSession?

    required init() {}

    @MainActor
    func startRecordingSession(investigator: AccountDetails) async throws {
        // Request is coming from MainActor and we need to access active patient from main actor.
        // Therefore, we stay on main actor before we switch to @EEGProcessing actor for file I/O.
        guard let patient = patientList.activePatient else {
            throw EEGRecordingError.noSelectedPatient
        }

        try await _startRecordingSession(investigator: investigator, patient: patient)
    }

    @EEGProcessing
    private func _startRecordingSession(investigator: AccountDetails, patient: Patient) async throws {
        guard let device = deviceCoordinator.connectedDevice else {
            throw EEGRecordingError.noConnectedDevice
        }


        let recordingId = UUID()

        // file I/O should only happen on background thread.
        let url = try Self.createTempRecordingFile(id: recordingId)

        try await device.prepareRecording()

        let session = try EEGRecordingSession(
            id: recordingId,
            url: url,
            patient: patient,
            device: device,
            investigatorCode: investigator.investigatorCode
        )

        try await device.startRecording(session)

        // We set the recording session after recording was enabled on the device.
        // Otherwise, we would navigate away to early from the Splash screen and would result in this
        // task being cancelled.
        await MainActor.run {
            self.recordingSession = session
        }
    }

    @MainActor
    func runRecordingAndSave() async {
        guard let recordingSession else {
            return
        }

        await recordingSession.runRecording()

        guard !Task.isCancelled else {
            await handleCancelledRecording()
            return
        }

        await recordingSession.saveRecording(standard: standard, patientList: patientList, connectedDevice: deviceCoordinator.connectedDevice)
    }

    @MainActor
    func retryUpload() async {
        guard let recordingSession else {
            return
        }


        await recordingSession.retryFileUpload(standard: standard, patientList: patientList)
    }

    @MainActor
    private func handleCancelledRecording() async {
        defer {
            self.recordingSession = nil
        }

        if let device = deviceCoordinator.connectedDevice {
            do {
                try await device.stopRecording()
            } catch {
                // nothing we can really do about
                Self.logger.error("Failed to stop recording for device: \(error)")
            }
        }
    }
}


extension EEGRecordings {
    static func tempFileUrl(id: UUID) -> URL {
        FileManager.default.temporaryDirectory.appending(path: "neuronest-recording-\(id.uuidString).bdf")
    }

    @EEGProcessing
    static func createTempRecordingFile(id: UUID) throws -> URL {
        let url = tempFileUrl(id: id)
        if FileManager.default.fileExists(atPath: url.path) {
            throw EEGRecordingError.unexpectedErrorStart
        }
        let created = FileManager.default.createFile(atPath: url.path, contents: nil)
        if !created {
            logger.error("Failed to create file at \(url.path)")
            throw EEGRecordingError.unexpectedErrorStart
        }
        return url
    }

    @EEGProcessing
    static func tempRecordingFileURL(id: UUID) -> URL? {
        let url = EEGRecordings.tempFileUrl(id: id)
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }

    @EEGProcessing
    static func removeTempRecordingFile(id: UUID) throws {
        let url = tempFileUrl(id: id)
        try FileManager.default.removeItem(at: url)
    }
}
