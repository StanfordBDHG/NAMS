//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension EEGViewModel {
    convenience init(mock: MockEEGDevice) {
        self.init(deviceManager: MockDeviceManager())
        let activeDevice = ConnectedDevice(device: mock)
        activeDevice.connect()
        self.activeDevice = activeDevice
    }
}
