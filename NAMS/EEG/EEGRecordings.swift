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
import SpeziViews // TODO: remove?


@Observable
class EEGRecordings: Module, EnvironmentAccessible, DefaultInitializable {
    private static let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

    @StandardActor @ObservationIgnored private var standard: NAMSStandard

    @Dependency @ObservationIgnored private var deviceCoordinator: DeviceCoordinator
    @Dependency @ObservationIgnored private var patientList: PatientListModel

    private(set) var recordingSession: EEGRecordingSession?

    @MainActor var recordingState: ViewState = .idle

    required init() {}

    @MainActor
    func startRecordingSession(investigator: AccountDetails) async throws {
        guard let patient = patientList.activePatient else {
            throw EEGRecordingError.noSelectedPatient
        }

        guard let device = deviceCoordinator.connectedDevice else {
            throw EEGRecordingError.noConnectedDevice
        }


        let recordingId = UUID()

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
        self.recordingSession = session
    }

    @MainActor
    func saveRecording() async {
        // TOOD: actor isolation and everything?
        guard let recordingSession else {
            return
        }

        recordingState = .processing

        do {
            try await recordingSession.close()
        } catch {
            Self.logger.error("Failed to close file writer of recording session: \(error)")
        }

        async let result: Void? = deviceCoordinator.connectedDevice?.stopRecording()

        let url = EEGRecordings.tempFileUrl(id: recordingSession.id)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                // TODO: pipe back the error?
                try await standard.uploadEEGRecording(file: url, recordingId: recordingSession.id, patientId: recordingSession.patientId, format: .bdf)
            } catch {
                Self.logger.error("Failed to upload eeg recording: \(error)")
                recordingState = .error(AnyLocalizedError(error: error)) // TODO: default error?
                // TODO: what to do with the error?
            }
        } else {
            // TODO: this is an erronous state, but we wan't recover right?
        }


        do {
            try await result // TODO: errors?
        } catch {
            Self.logger.error("Failed to stop sample collection on bluetooth device: \(error)")
        }
        recordingState = .idle
    }

    @MainActor
    func stopRecordingSession() async throws {
        defer {
            self.recordingSession = nil
        }

        // TODO: how to deal with the errors?
        if let recordingSession {
            do {
                try await recordingSession.close()

                // TODO: upload to firebase?

                try EEGRecordings.removeTempRecordingFile(id: recordingSession.id)
            } catch {
                Self.logger.error("Failed to close the recording session: \(error)")
            }
        }

        if let device = deviceCoordinator.connectedDevice {
            do {
                try await device.stopRecording()
            } catch {
                Self.logger.error("Failed to stop recording for device: \(error)")
            }
        }

        // TODO: delete file!

        // TODO: save or delete file eventually?
    }
}


extension EEGRecordings {
    @inlinable
    static func tempFileUrl(id: UUID) -> URL {
        FileManager.default.temporaryDirectory.appending(path: "neuronest-recording-\(id.uuidString).bdf")
    }

    static func createTempRecordingFile(id: UUID) throws -> URL {
        let url = tempFileUrl(id: id)
        if FileManager.default.fileExists(atPath: url.path) {
            throw EEGRecordingError.unexpectedError
        }
        let created = FileManager.default.createFile(atPath: url.path, contents: nil)
        if !created {
            logger.error("Failed to create file at \(url.path)")
            throw EEGRecordingError.unexpectedError
        }
        return url
    }

    static func removeTempRecordingFile(id: UUID) throws {
        let url = tempFileUrl(id: id)
        try FileManager.default.removeItem(at: url)
    }
}
