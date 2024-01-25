//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
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
