//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


private class ConnectionListener: DeviceConnectionListener {
    private static let sampleRate = 60

    private let mockDevice: MockEEGDevice
    private let device: ConnectedDevice

    private let eegMeasurementGenerators: [EEGFrequency: EEGMeasurementGenerator]

    init(mock mockDevice: MockEEGDevice, device: ConnectedDevice) {
        self.mockDevice = mockDevice
        self.device = device
        self.eegMeasurementGenerators = EEGFrequency.allCases.reduce(into: [:]) { result, frequency in
            result[frequency] = EEGMeasurementGenerator(sampleRate: Self.sampleRate)
        }
    }


    func connect() {
        if mockDevice.connectionState.associatedConnection {
            device.state = mockDevice.connectionState
            if device.state.establishedConnection {
                onConnected()
            }
            return
        }

        change(connectionState: .connecting)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            change(connectionState: .connected)
            onConnected()
        }
    }

    func onConnected() {
        device.remainingBatteryPercentage = 75
        device.aboutInformation = [
            "SERIAL_NUMBER": "AA BB CC DD",
            "FIRMWARE_VERSION": "1.2.0"
        ]

        // timer cancels itself based on the connection state
        let timer = Timer(timeInterval: 1.0 / Double(Self.sampleRate), repeats: true, block: generateRecording)
        RunLoop.main.add(timer, forMode: .common)

        Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            device.fit = HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .poor, tp10Fit: .good)
            device.wearingHeadband = true
        }
    }

    func change(connectionState: ConnectionState) {
        mockDevice.connectionState = connectionState
        device.state = connectionState
    }

    @Sendable
    private func generateRecording(timer: Timer) {
        if mockDevice.connectionState != .connected {
            timer.invalidate()
            return
        }

        for (frequency, generator) in eegMeasurementGenerators {
            device.measurements[frequency, default: []]
                .append(generator.next())
        }
    }
}


class MockEEGDevice: EEGDevice {
    let name: String
    let model: String
    let macAddress: String

    var connectionState: ConnectionState
    var rssi: Double = 0
    var lastDiscoveredTime: Double = 0

    private var lastListener: ConnectionListener?

    init(name: String, model: String, macAddress: String? = nil, state: ConnectionState = .unknown) {
        self.name = name
        self.model = model
        self.macAddress = macAddress ?? (0..<6)
            .map { _ in String(format: "%02X", Int.random(in: 0...255)) }
            .joined(separator: ":")
        self.connectionState = state
    }


    func connect(state device: ConnectedDevice) -> DeviceConnectionListener {
        let listener = ConnectionListener(mock: self, device: device)
        listener.connect()
        self.lastListener = listener
        return listener
    }

    func disconnect() {
        lastListener?.change(connectionState: .disconnected)
        connectionState = .disconnected
        lastListener = nil
    }
}
