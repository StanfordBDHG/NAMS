//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import CoreBluetooth
import Foundation
import OSLog


class EEGViewModel: ObservableObject {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

    private let deviceManager: DeviceManager

    @Published var nearbyDevices: [EEGDevice] = []
    @Published var activeDevice: ConnectedDevice?

    private var deviceManagerCancelable: AnyCancellable?
    private var activeDeviceCancelable: AnyCancellable?

    init(deviceManager: DeviceManager) {
        self.deviceManager = deviceManager
        self.deviceManagerCancelable = nil

        self.deviceManagerCancelable = self.deviceManager.devicePublisher.sink { [weak self] devices in
            self?.nearbyDevices = devices
        }
    }

    @MainActor
    private func refreshNearbyDevices() {
        self.nearbyDevices = self.deviceManager.retrieveDeviceList()
    }

    @MainActor
    func startScanning() {
        self.deviceManager.startScanning()
        refreshNearbyDevices()
    }

    @MainActor
    func stopScanning(state: CBManagerState) {
        self.deviceManager.stopScanning()

        if state == .poweredOn {
            refreshNearbyDevices()
        }
    }

    @MainActor
    func tapDevice(_ device: EEGDevice) {
        if let activeDevice {
            // either we tapped on the same Muse or on another one, in any case disconnect the currently active Muse
            activeDevice.disconnect()
            activeDeviceCancelable?.cancel()
            activeDeviceCancelable = nil
            self.activeDevice = nil


            if activeDevice.device.macAddress == device.macAddress {
                // if the tapped one was the active one return
                return
            }
        }

        let activeDevice = ConnectedDevice(device: device)
        activeDeviceCancelable = activeDevice.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            if case .disconnected = activeDevice.state { // TODO do we handle reconnects properly?
                self?.activeDeviceCancelable?.cancel()
                self?.activeDeviceCancelable = nil
                self?.activeDevice = nil
            }
        }

        activeDevice.connect()
        self.activeDevice = activeDevice
    }
}
