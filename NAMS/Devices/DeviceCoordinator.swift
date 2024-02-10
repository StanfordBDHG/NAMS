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


    var shouldAutoConnectBiopot: Bool {
        autoConnectOption == .background && !isConnected
    }


    required init() {}


    /// Shorthand for easy previewing devices.
    init(mock: ConnectedDevice) {
        self.connectedDevice = mock
    }


    /// Device is tapped by the user in the nearby devices view.
    @MainActor
    func tapDevice(_ device: ConnectedDevice) async {
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
        self.associateDevice(device)
    }

    @MainActor
    func notifyConnectedDevice(_ device: ConnectedDevice) {
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
            // TODO: deal with auto connecting muse device (after reconnect?)
            self.connectedDevice = nil
        }
    }
}
