//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import Spezi
import SpeziBluetooth

enum SomeDevice { // TODO: move to separate file
#if MUSE
    case muse(_ muse: MuseDevice)
#endif
    case biopot(_ biopot: BiopotDevice)
    case mock(_ mock: MockDevice)

    func connect() async {
        switch self {
#if MUSE
        case let .muse(muse):
            muse.connect()
#endif
        case let .biopot(biopot):
            await biopot.connect()
        case let .mock(mock):
            mock.connect()
        }
    }

    func disconnect() async {
        switch self {
#if MUSE
        case let .muse(muse):
            muse.disconnect()
#endif
        case let .biopot(biopot):
            await biopot.disconnect()
        case let .mock(mock):
            mock.disconnect()
        }
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        switch self {
            #if MUSE
        case let .muse(muse):
            try await muse.startRecording(session)
            #endif
        case let .biopot(biopot):
            try await biopot.startRecording(session)
        case let .mock(mock):
            try await mock.startRecording(session)
        }
    }

    @MainActor
    func stopRecording() async throws {
        switch self {
            #if MUSE
        case let .muse(muse):
            try await muse.stopRecording()
            #endif
        case let .biopot(biopot):
            try await biopot.stopRecording()
        case let .mock(mock):
            try await mock.stopRecording()
        }
    }
}

extension SomeDevice: Hashable {}


extension SomeDevice: GenericBluetoothPeripheral {
    var label: String {
        switch self {
#if MUSE
        case let .muse(muse):
            muse.label
#endif
        case let .biopot(biopot):
            biopot.label
        case let .mock(mock):
            mock.label
        }
    }

    var state: SpeziBluetooth.PeripheralState {
        switch self {
#if MUSE
        case let .muse(muse):
            muse.state
#endif
        case let .biopot(biopot):
            biopot.state
        case let .mock(mock):
            mock.state
        }
    }

    // TODO: forward all the other protocol requirements!!
}


@Observable
class DeviceCoordinator: Module, EnvironmentAccessible, DefaultInitializable {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "DeviceCoordinator")

    private(set) var connectedDevice: SomeDevice?

    var isConnected: Bool {
        connectedDevice != nil
    }


    required init() {}


    /// Shorthand for easy previewing devices.
    init(mock: MockDevice) {
        self.connectedDevice = .mock(mock)
    }


    @MainActor
    func tapDevice(_ device: SomeDevice) async {
        if let connectedDevice {
            logger.info("Disconnecting previously connected device \(connectedDevice.label)...")
            // either we tapped on the same device or on another one, in any case disconnect the currently connected device
            await connectedDevice.disconnect()
            self.connectedDevice = nil

            if connectedDevice == device {
                // if the tapped one was the connected one return
                return
            }
        }

        logger.info("Connecting to nearby device \(device.label)...")

        await device.connect()
        self.connectedDevice = device
    }

    func hintDisconnect() {
        // TODO: this must also trigger on an external disconnect!
        self.connectedDevice = nil // This is not ideal right now
    }
}
