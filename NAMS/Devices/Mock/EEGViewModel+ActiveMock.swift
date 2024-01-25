//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


extension EEGViewModel {
    convenience init(mock: MockEEGDevice) {
        self.init(deviceManager: MockDeviceManager())
        let activeDevice = ConnectedDevice(device: mock, session: recordingSessionBinding)
        sinkActiveDevice(device: activeDevice)
        activeDevice.connect()
        self.activeDevice = activeDevice
    }
}
