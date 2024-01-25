//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


protocol EEGDevice: AnyObject {
    var name: String { get }
    var macAddress: String { get }
    var model: String { get }

    var connectionState: ConnectionState { get }
    var rssi: Double { get }

    var lastDiscoveredTime: Double { get }

    func connect(state device: ConnectedDevice) -> DeviceConnectionListener

    func disconnect()
}
