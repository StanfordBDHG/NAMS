//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
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
    func stopScanning(refreshNearby: Bool = true) {
        self.deviceManager.stopScanning()

        if refreshNearby {
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
        sinkActiveDevice(device: activeDevice)

        activeDevice.connect()
        self.activeDevice = activeDevice
    }

    func sinkActiveDevice(device: ConnectedDevice) {
        activeDeviceCancelable = device.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            if case .disconnected = device.state {
                self?.activeDeviceCancelable?.cancel()
                self?.activeDeviceCancelable = nil
                self?.activeDevice = nil
            }
        }
    }
}
