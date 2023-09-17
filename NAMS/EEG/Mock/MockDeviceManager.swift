//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine


class MockDeviceManager: DeviceManager {
    @Published var nearbyDevices: [EEGDevice] = []

    var devicePublisher: Published<[EEGDevice]>.Publisher {
        $nearbyDevices
    }


    init() {}


    func startScanning() {
        // TODO mock device!
    }

    func stopScanning() {
    }


    func retrieveDeviceList() -> [EEGDevice] {
        nearbyDevices
    }
}
