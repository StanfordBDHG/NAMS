//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi

enum EEGRecordingError: LocalizedError {
    case noConnectedDevice


    var errorDescription: String? {
        switch self {
        case .noConnectedDevice:
            String(localized: "No connected device")
        }
    }

    var failureReason: String? {
        switch self {
        case .noConnectedDevice:
            String(localized: "EEG recording could not be started as no connected device was found.")
        }
    }
}


@Observable
class EEGRecordings: Module, EnvironmentAccessible, DefaultInitializable {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

    @Dependency @ObservationIgnored private var deviceCoordinator: DeviceCoordinator

    private(set) var recordingSession: EEGRecordingSession?

    required init() {}

    @MainActor
    func startRecordingSession() async throws {
        let session = EEGRecordingSession()
        self.recordingSession = session

        guard let device = deviceCoordinator.connectedDevice else {
            throw EEGRecordingError.noConnectedDevice
        }

        // TODO: handle the case where the device disconnects when an ongoing recording is in progress? => Issue
        try await device.startRecording(session)
    }

    @MainActor
    func stopRecordingSession() async throws {
        if let device = deviceCoordinator.connectedDevice {
            try await device.stopRecording()
        }
        self.recordingSession = nil
    }
}
