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

    required init() {}

    @MainActor
    func createRecordingSession(investigator: AccountDetails) async throws -> EEGRecordingSession {
        // Request is coming from MainActor and we need to access active patient from main actor.
        // Therefore, we stay on main actor before we switch to @EEGProcessing actor for file I/O.
        guard let patient = patientList.activePatient else {
            throw EEGRecordingError.noSelectedPatient
        }

        return try await _createRecordingSession(investigator: investigator, patient: patient)
    }

    @EEGProcessing
    private func _createRecordingSession(investigator: AccountDetails, patient: Patient) async throws -> EEGRecordingSession {
        guard let device = deviceCoordinator.connectedDevice else {
            throw EEGRecordingError.noConnectedDevice
        }


        let recordingId = UUID()

        let stream = try await device.startRecording()

        // file I/O should only happen on background thread.
        let url = try Self.createTempRecordingFile(id: recordingId)

        do {
            // Once the recording session is created, the file is owned by the session (and must be cleared by it).
            return try EEGRecordingSession(
                id: recordingId,
                url: url,
                patient: patient,
                device: device,
                investigatorCode: investigator.investigatorCode,
                stream: stream
            )
        } catch {
            // make sure we clean up orphaned files.
            try? Self.removeTempRecordingFile(id: recordingId)
            throw error
        }
    }

    @MainActor
    func runAndSave(recording: EEGRecordingSession) async {
        await recording.runRecording()

        guard !Task.isCancelled else {
            return // do not save cancelled recordings
        }

        await recording.saveRecording(standard: standard, patientList: patientList, connectedDevice: deviceCoordinator.connectedDevice)
    }

    @MainActor
    func retryUpload(for recording: EEGRecordingSession) async {
        await recording.retryFileUpload(standard: standard, patientList: patientList)
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
