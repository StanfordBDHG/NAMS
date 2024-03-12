//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import EDFFormat
import SpeziBluetooth


protocol SomeConnectedDevice: GenericBluetoothPeripheral { // TODO: new name for that protocol! (maybe move?)
    /// The string description of the equipment used for the BDF file.
    var equipmentCode: String { get }
    /// Description of signals expected in each data record.
    var signalDescription: [Signal]? { get } // swiftlint:disable:this discouraged_optional_collection
    /// The duration of a single data record in seconds.
    var recordDuration: Int { get }

    func connect() async

    func disconnect() async

    func prepareRecording() async throws

    func startRecording(_ session: EEGRecordingSession) async throws

    func stopRecording() async throws

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void)
}


enum ConnectedDevice {
    #if MUSE
    case muse(_ muse: MuseDevice)
    #endif
    case biopot(_ biopot: BiopotDevice)
    case mock(_ mock: MockDevice)

    private var underlyingDevice: SomeConnectedDevice {
        switch self {
#if MUSE
        case let .muse(muse):
            muse
#endif
        case let .biopot(biopot):
            biopot
        case let .mock(mock):
            mock
        }
    }
}


extension ConnectedDevice: Hashable {}


extension ConnectedDevice: SomeConnectedDevice {
    var label: String {
        underlyingDevice.label
    }

    var state: PeripheralState {
        underlyingDevice.state
    }

    var accessibilityLabel: String {
        underlyingDevice.accessibilityLabel
    }

    var requiresUserAttention: Bool {
        underlyingDevice.requiresUserAttention
    }

    var equipmentCode: String {
        underlyingDevice.equipmentCode
    }

    var signalDescription: [Signal]? { // swiftlint:disable:this discouraged_optional_collection
        underlyingDevice.signalDescription
    }

    var recordDuration: Int {
        underlyingDevice.recordDuration
    }


    @MainActor
    func connect() async {
        await underlyingDevice.connect()
    }

    @MainActor
    func disconnect() async {
        await underlyingDevice.disconnect()
    }

    @MainActor
    func prepareRecording() async throws {
        try await underlyingDevice.prepareRecording()
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        try await underlyingDevice.startRecording(session)
    }

    @MainActor
    func stopRecording() async throws {
        try await underlyingDevice.stopRecording()
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void) {
        underlyingDevice.setupDisconnectHandler(handler)
    }
}
