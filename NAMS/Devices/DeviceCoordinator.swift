//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi
import SpeziBluetooth
import SwiftUI


@Observable
class DeviceCoordinator: Module, EnvironmentAccessible, DefaultInitializable {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "DeviceCoordinator")

    private(set) var connectedDevice: ConnectedDevice?

    @AppStorage(StorageKeys.autoConnectOption)
    @ObservationIgnored private var _autoConnectOption: AutoConnectConfiguration = .off
    @AppStorage(StorageKeys.enableMockDevice)
    @ObservationIgnored private var _enableMockDevice = false

    var isConnected: Bool {
        connectedDevice != nil
    }

    var autoConnectOption: AutoConnectConfiguration {
        get {
            access(keyPath: \.autoConnectOption)
            return _autoConnectOption
        }
        set {
            withMutation(keyPath: \.autoConnectOption) {
                _autoConnectOption = newValue
            }
        }
    }

    var enableMockDevice: Bool {
        get {
            access(keyPath: \.enableMockDevice)
#if TEST
            // always enabled in TEST builds
            return true
#else
            return _enableMockDevice
#endif
        }
        set {
            withMutation(keyPath: \.autoConnectOption) {
                _enableMockDevice = newValue
            }
        }
    }


    var shouldAutoConnectBiopot: Bool {
        autoConnectOption == .on && !isConnected
    }

    var shouldAutoConnectBiopotBackground: Bool {
        autoConnectOption == .background && !isConnected
    }


    required init() {}


    /// Shorthand for easy previewing devices.
    init(mock: ConnectedDevice) {
        self.connectedDevice = mock
    }


    /// Device is tapped by the user in the nearby devices view.
    @MainActor
    func tapDevice(_ device: ConnectedDevice) async throws {
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

        try await device.connect()
        self.associateDevice(device)
    }

    @MainActor
    func notifyConnectingDevice(_ device: ConnectedDevice) {
        if let connectedDevice {
            if connectedDevice != device {
                logger.info("Nearby device automatically connected, though we already have a connected device. Disconnecting it again...")
                Task {
                    await device.disconnect()
                }
            }
        } else {
            logger.info("Nearby device automatically connected: \(device.label)")
            self.associateDevice(device)
        }
    }

    @MainActor
    private func associateDevice(_ device: ConnectedDevice) {
        assert(connectedDevice == nil, "Cannot override an existing device!")
        self.connectedDevice = device
        device.setupDisconnectHandler { @MainActor [weak self] device in
            guard let self = self,
                  self.connectedDevice == device else {
                return
            }
            logger.debug("Removing association for device disconnecting in background: \(device.label).")
            self.connectedDevice = nil
        }
    }
}
