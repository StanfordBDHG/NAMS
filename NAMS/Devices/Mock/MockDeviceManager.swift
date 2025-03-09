//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
@_spi(APISupport)
import SpeziBluetooth


@Observable
@MainActor
final class MockDeviceManager {
    @MainActor static let defaultNearbyDevices: [MockDevice] = [
        MockDevice(name: "Mock Device 1"),
        MockDevice(name: "Mock Device 2")
    ]

    private let storedDevicesList: [MockDevice]

    @ObservationIgnored private var previouslyDiscovered = false
    var nearbyDevices: [MockDevice] = []
    @ObservationIgnored private var task: Task<Void, Never>? {
        willSet {
            task?.cancel()
        }
    }


    init(nearbyDevices: [MockDevice], immediate: Bool = false) {
        self.storedDevicesList = nearbyDevices
        if immediate {
            self.nearbyDevices = nearbyDevices
        }
    }


    @MainActor
    convenience init(immediate: Bool = false) {
        self.init(nearbyDevices: MockDeviceManager.defaultNearbyDevices, immediate: immediate)
    }


    func startScanning() {
        if !previouslyDiscovered {
            task = Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else {
                    return
                }
                nearbyDevices = storedDevicesList
                previouslyDiscovered = true
            }
        } else {
            nearbyDevices = storedDevicesList
        }
    }

    func stopScanning() {
        task = Task { @MainActor in
            nearbyDevices.removeAll { device in
                device.state == .disconnected
            }
        }
    }
}


extension MockDeviceManager: BluetoothScanner {
    typealias ScanningState = EmptyScanningState

    var hasConnectedDevices: Bool {
        nearbyDevices.contains { device in
            device.state != .disconnected
        }
    }

    @MainActor
    func scanNearbyDevices(_ state: EmptyScanningState) async {
        self.startScanning()
    }

    func updateScanningState(_ state: EmptyScanningState) async {}
}
