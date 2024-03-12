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


enum EEGRecordingError: LocalizedError {
    case noSelectedPatient
    case noConnectedDevice
    case deviceNotReady
    case unexpectedError


    var errorDescription: String? {
        switch self {
        case .noSelectedPatient:
            String(localized: "No Patient Selected")
        case .noConnectedDevice:
            String(localized: "No Connected Device")
        case .deviceNotReady:
            String(localized: "Device Not Ready")
        case .unexpectedError:
            String(localized: "Unexpected Error")
        }
    }

    var failureReason: String? {
        switch self {
        case .noSelectedPatient:
            String(localized: "EEG recording could not be started as no patient was selected.")
        case .noConnectedDevice:
            String(localized: "EEG recording could not be started as no connected device was found.")
        case .deviceNotReady:
            String(localized: "There was an unexpected error when preparing the connected device for the recording.")
        case .unexpectedError:
            String(localized: "Unexpected error occurred while trying to start the recording. Please try again!")
        }
    }
}


@Observable
class EEGRecordings: Module, EnvironmentAccessible, DefaultInitializable {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

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
        let url = FileManager.default.temporaryDirectory.appending(path: "neuronest-recording-\(recordingId).bdf")
        if FileManager.default.fileExists(atPath: url.path) {
            throw EEGRecordingError.unexpectedError
        }
        let created = FileManager.default.createFile(atPath: url.path, contents: nil)
        if !created {
            logger.error("Failed to create file at \(url.path)")
            throw EEGRecordingError.unexpectedError // TODO: more specific error?
        }

        try await device.prepareRecording()

        // TODO: first start recording session (so we have all the prefiltering data etc?)
        //  => more accurate start date?

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
    }
}
