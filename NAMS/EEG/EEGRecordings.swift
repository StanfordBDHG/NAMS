//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi


// TODO: search and replace .environment(EEGRecordings())

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
            // TODO: throw an error!
            logger.error("Tried to start EEG recording but no connected device was found!")
            return
        }

        // TODO: get current device and enable recording session? on device coordinator (so they can handle changing devices?)
        // TODO: handle the case where the device disconnects when an ongoing recording is in progress?
        try await device.startRecording(session)
    }

    @MainActor
    func stopRecordingSession() {
        self.recordingSession = nil
        if let device = deviceCoordinator.connectedDevice {
            device.stopRecording() // TODO async?
        }
    }
}
