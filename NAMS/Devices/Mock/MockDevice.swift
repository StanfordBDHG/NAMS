//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import Foundation
import SpeziBluetooth


@Observable
class MockDevice {
    private static let sampleRate = 60

    let id: UUID
    let name: String
    private let eegMeasurementGenerators: [EEGFrequency: MockMeasurementGenerator]

    var state: PeripheralState
    var deviceInformation: MuseDeviceInformation? // we are just reusing muse data model

    /// The currently associated recording session.
    @MainActor private var recordingSession: EEGRecordingSession?
    @MainActor private var disconnectHandler: ((ConnectedDevice) -> Void)?

    var connectionState: ConnectionState {
        switch state {
        case .disconnected:
            return .disconnected
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        case .disconnecting:
            return .disconnected
        }
    }

    @ObservationIgnored private var eegTimer: Timer? {
        willSet {
            eegTimer?.invalidate()
        }
    }
    @ObservationIgnored private var task: Task<Void, Never>? {
        willSet {
            task?.cancel()
        }
    }


    @MainActor
    init(name: String, state: PeripheralState = .disconnected) {
        self.id = UUID()
        self.name = name
        self.state = state
        self.eegMeasurementGenerators = EEGFrequency.allCases.reduce(into: [:]) { result, frequency in
            result[frequency] = MockMeasurementGenerator(sampleRate: Self.sampleRate)
        }

        switch state {
        case .connecting:
            connect()
        case .connected:
            handleConnected()
        case .disconnecting:
            disconnect()
        case .disconnected:
            break
        }
    }


    @MainActor
    func setupDisconnectHandler(_ handler: @escaping (ConnectedDevice) -> Void) {
        self.disconnectHandler = handler
    }


    func connect() {
        state = .connecting
        task = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled,
                  let self = self,
                  self.state == .connecting else {
                return
            }
            self.state = .connected
            self.handleConnected()
        }
    }

    private func handleConnected() {
        self.deviceInformation = MuseDeviceInformation(
            serialNumber: "0xAABBCCDD",
            firmwareVersion: "1.2",
            hardwareVersion: "1.0",
            remainingBatteryPercentage: 75
        )

        task = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled,
                  let self = self,
                  self.state == .connected,
                  let info = self.deviceInformation else {
                return
            }
            info.fit = HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .poor, tp10Fit: .good)
            info.wearingHeadband = true
        }
    }

    @MainActor
    func disconnect() {
        state = .disconnected
        deviceInformation = nil
        task = nil
        eegTimer = nil
        if let disconnectHandler {
            self.disconnectHandler = nil
            disconnectHandler(.mock(self))
        }
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        self.recordingSession = session

        // schedule timer to generate fake EEG data
        let timer = Timer(timeInterval: 1.0 / Double(Self.sampleRate), repeats: true, block: generateRecording)
        RunLoop.main.add(timer, forMode: .common)
        self.eegTimer = timer

        generateRecording(timer: timer) // make sure there is data instantly
    }

    @MainActor
    func stopRecording() async throws {
        self.eegTimer = nil
        self.recordingSession = nil
    }

    @Sendable
    private func generateRecording(timer: Timer) {
        // its running on the main RunLoop so this is safe to assume
        MainActor.assumeIsolated {
            guard let recordingSession,
                  state == .connected else {
                timer.invalidate()
                return
            }

            for (frequency, generator) in eegMeasurementGenerators {
                let series = generator.next()
                recordingSession.append(series: series, for: frequency)
            }
        }
    }
}


extension MockDevice: GenericBluetoothPeripheral {
    var label: String {
        name
    }
}


extension MockDevice: Identifiable {}


extension MockDevice: Hashable {
    static func == (lhs: MockDevice, rhs: MockDevice) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
