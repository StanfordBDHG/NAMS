//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


struct ConnectionListener: DeviceConnectionListener {
    private let mockDevice: MockEEGDevice
    private let device: ConnectedDevice

    init(mock mockDevice: MockEEGDevice, device: ConnectedDevice) {
        self.mockDevice = mockDevice
        self.device = device
    }

    func connect() {
        if mockDevice.connectionState != .unknown && mockDevice.connectionState != .disconnected {
            device.state = mockDevice.connectionState
            if device.state == .connected {
                onConnected()
            }
            return
        }

        change(connectionState: .connecting)
        Task {
            try? await Task.sleep(for: .seconds(2))
            change(connectionState: .connected)
            onConnected()
        }
    }

    func onConnected() {
        device.remainingBatteryPercentage = 75
    }

    func change(connectionState: ConnectionState) {
        mockDevice.connectionState = connectionState
        device.state = connectionState
    }
}

class MockEEGDevice: EEGDevice {
    let name: String
    let model: String
    let macAddress: String

    var connectionState: ConnectionState
    var rssi: Double = 0
    var lastDiscoveredTime: Double = 0

    func connect(state device: ConnectedDevice) -> DeviceConnectionListener {
        let listener = ConnectionListener(mock: self, device: device)
        listener.connect()
        return listener
    }

    func disconnect() {
        connectionState = .disconnected
    }


    init(name: String, model: String, macAddress: String? = nil, state: ConnectionState = .unknown) {
        self.name = name
        self.model = model
        self.macAddress = macAddress ?? (0..<6)
            .map { _ in String(format: "%02X", Int.random(in: 0...255)) }
            .joined(separator: ":")
        self.connectionState = state
    }
}
