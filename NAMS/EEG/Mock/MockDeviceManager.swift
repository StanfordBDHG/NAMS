//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine


class MockDeviceManager: DeviceManager {
    static var defaultNearbyDevices: [EEGDevice] {
        [
            MockEEGDevice(name: "Device 2", model: "Mock"),
            MockEEGDevice(name: "Device 1", model: "Mock")
        ]
    }

    @Published var nearbyDevices: [EEGDevice] = []

    let deviceList: [EEGDevice]

    var devicePublisher: Published<[EEGDevice]>.Publisher {
        $nearbyDevices
    }


    init(nearbyDevices: [EEGDevice] = MockDeviceManager.defaultNearbyDevices, immediate: Bool = false) {
        self.deviceList = nearbyDevices
        if immediate {
            self.nearbyDevices = deviceList
        }
    }


    func startScanning() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            nearbyDevices = deviceList
        }
    }

    func stopScanning() {}

    func retrieveDeviceList() -> [EEGDevice] {
        nearbyDevices
    }
}
