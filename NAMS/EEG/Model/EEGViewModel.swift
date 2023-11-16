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


@Observable
class EEGViewModel {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseViewModel")

    private let deviceManager: DeviceManager

    var nearbyDevices: [EEGDevice] = []
    var activeDevice: ConnectedDevice?

    private var deviceManagerCancelable: AnyCancellable?
    private var activeDeviceCancelable: AnyCancellable?


    init(deviceManager: DeviceManager) {
        self.deviceManager = deviceManager
        self.deviceManagerCancelable = nil

        self.deviceManagerCancelable = self.deviceManager.devicePublisher.sink { [weak self] devices in
            self?.nearbyDevices = devices
            self?.logger.debug("Updated nearby devices to \(devices.count) in total.")
        }
    }


    @MainActor
    private func refreshNearbyDevices() {
        self.nearbyDevices = self.deviceManager.retrieveDeviceList()
    }

    @MainActor
    func startScanning() {
        logger.debug("Start scanning for nearby devices...")
        self.deviceManager.startScanning()
        refreshNearbyDevices()

        if !nearbyDevices.isEmpty {
            logger.debug("Found \(self.nearbyDevices.count) nearby devices immediately.")
        }
    }

    @MainActor
    func stopScanning(refreshNearby: Bool = true) {
        logger.debug("Stopped scanning for nearby devices!")
        self.deviceManager.stopScanning()

        if refreshNearby {
            refreshNearbyDevices()
            logger.debug("We maintain \(self.nearbyDevices.count) devices after scanning stop.")
        }
    }

    @MainActor
    func tapDevice(_ device: EEGDevice) {
        if let activeDevice {
            logger.info("Disconnecting previously connected device \(activeDevice.device.name)...")
            // either we tapped on the same Muse or on another one, in any case disconnect the currently active Muse
            activeDevice.disconnect()
            clearActiveDevice()


            if activeDevice.device.macAddress == device.macAddress {
                // if the tapped one was the active one return
                return
            }
        }

        logger.info("Connecting to nearby devices \(device.name)...")

        let activeDevice = ConnectedDevice(device: device)
        sinkActiveDevice(device: activeDevice)

        activeDevice.connect()
        self.activeDevice = activeDevice
    }

    func sinkActiveDevice(device: ConnectedDevice) {
        activeDeviceCancelable = device.$publishedState.sink { [weak self] state in
            if case .disconnected = state {
                self?.clearActiveDevice()
            }
        }
    }

    private func clearActiveDevice() {
        activeDeviceCancelable?.cancel()
        activeDeviceCancelable = nil
        activeDevice = nil
    }
}
