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

    @Dependency @ObservationIgnored private var deviceCoordinator: DeviceCoordinator
    @Dependency @ObservationIgnored private var patientList: PatientListModel

    private(set) var recordingSession: EEGRecordingSession?

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
    func stopRecordingSession() async throws {
        if let device = deviceCoordinator.connectedDevice {
            try await device.stopRecording()
        }
        self.recordingSession = nil

        // TODO: save or delete file eventually?
    }
}


extension EEGRecordings {
    static func createTempRecordingFile(id: UUID) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "neuronest-recording-\(id.uuidString).bdf")
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
        let url = FileManager.default.temporaryDirectory.appending(path: "neuronest-recording-\(id.uuidString).bdf")
        try FileManager.default.removeItem(at: url)
    }
}
