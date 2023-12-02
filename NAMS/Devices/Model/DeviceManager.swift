//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine


protocol DeviceManager: AnyObject {
    var devicePublisher: Published<[EEGDevice]>.Publisher { get }

    func startScanning()

    func stopScanning()
    
    func retrieveDeviceList() -> [EEGDevice]
}
