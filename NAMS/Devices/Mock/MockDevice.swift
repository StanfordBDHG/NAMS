//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation
import OSLog
import SpeziBluetooth
import SpeziDevices


@Observable
final class MockDevice: NAMSDevice, Sendable {
    private static let sampleRate = 60

    private let logger = Logger(subsystem: "edu.stanford.nams", category: "MockDevice")

    let id: UUID
    let name: String

    @MainActor private var measurementGenerator: MockMeasurementGenerator

    @MainActor var state: PeripheralState
    @MainActor var deviceInformation: MuseDeviceInformation? // we are just reusing muse data model
    @MainActor private var disconnectHandler: ((ConnectedDevice) -> Void)?

    @MainActor var equipmentCode: String {
        if let deviceInformation {
            "MOCK_\(deviceInformation.serialNumber)"
        } else {
            "MOCK"
        }
    }

    @MainActor var connectionState: ConnectionState {
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

    /// The currently associated recording session.
    @MainActor private var recordingStream: AsyncStream<CombinedEEGSample>.Continuation? {
        willSet {
            recordingStream?.finish()
        }
    }

    @ObservationIgnored @MainActor private var eegTimer: Timer? {
        willSet {
            eegTimer?.invalidate()
        }
    }
    @ObservationIgnored @MainActor private var task: Task<Void, Never>? {
        willSet {
            task?.cancel()
        }
    }

    var signalDescription: [Signal] {
        MockMeasurementGenerator.generatedLocations.map { location in
            Signal(
                label: .eeg(location: location, prefix: .micro),
                transducerType: "Mock Measurement Generator",
                sampleCount: Self.sampleRate,
                physicalMinimum: -20_000,
                physicalMaximum: 20_0000,
                digitalMinimum: -8_388_608,
                digitalMaximum: 8_388_607
            )
        }
    }

    var recordDuration: Int {
        1
    }

    @MainActor
    init(name: String, state: PeripheralState = .disconnected) {
        self.id = UUID()
        self.name = name
        self.state = state

        self.measurementGenerator = MockMeasurementGenerator(sampleRate: Self.sampleRate)

        switch state {
        case .connecting:
            connect()
        case .connected:
            handleConnected()
        case .disconnecting:
            Task { @MainActor in
                disconnect()
            }
        case .disconnected:
            break
        }
    }


    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void) {
        self.disconnectHandler = handler
    }


    @MainActor
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

    @MainActor
    private func handleConnected() {
        self.deviceInformation = MuseDeviceInformation(
            serialNumber: "0xAABBCCDD",
            firmwareVersion: "1.2",
            hardwareVersion: "1.0",
            sampleRate: Self.sampleRate,
            notchFilter: MuseDeviceInformation.notchDefault,
            afeGain: 2000,
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
    func startRecording() throws -> AsyncStream<CombinedEEGSample> {
        // schedule timer to generate fake EEG data
        let timer = Timer(timeInterval: 0.1, repeats: true) { timer in
            // its running on the main RunLoop so this is safe to assume
            MainActor.assumeIsolated {
                self.generateRecording(timer: timer)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.eegTimer = timer

        defer {
            generateRecording(timer: timer) // make sure there is data instantly
        }

        logger.info("Started recording for mock device.")

        return makeStream()
    }

    @MainActor
    private func makeStream() -> AsyncStream<CombinedEEGSample> {
        AsyncStream { continuation in
            continuation.onTermination = { [weak self] termination in
                guard case .cancelled = termination else {
                    return // we don't care about finished sequences!
                }

                Task { @EEGProcessing [weak self] in
                    try await self?.stopRecording()
                }
            }
            recordingStream = continuation
        }
    }

    @MainActor
    private func stopRecording() throws {
        logger.debug("Stopping recording for mock device ...")
        self.eegTimer = nil
        self.recordingStream = nil
        self.measurementGenerator = MockMeasurementGenerator(sampleRate: Self.sampleRate)
    }

    @MainActor
    private func generateRecording(timer: Timer) {
        guard let recordingStream,
              state == .connected else {
            timer.invalidate()
            return
        }

        let samples = measurementGenerator.next()
        Task { @EEGProcessing in
            for sample in samples {
                recordingStream.yield(sample)
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
