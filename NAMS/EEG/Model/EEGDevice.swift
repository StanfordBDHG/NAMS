//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
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
