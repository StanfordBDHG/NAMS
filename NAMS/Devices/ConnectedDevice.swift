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


enum ConnectedDevice {
    #if MUSE
    case muse(_ muse: MuseDevice)
    #endif
    case biopot(_ biopot: BiopotDevice)
    case mock(_ mock: MockDevice)

    private var underlyingDevice: NAMSDevice {
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


extension ConnectedDevice: NAMSDevice {
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

    var signalDescription: [Signal] {
        get throws {
            try underlyingDevice.signalDescription
        }
    }

    var recordDuration: Int {
        underlyingDevice.recordDuration
    }


    func connect() async {
        await underlyingDevice.connect()
    }

    func disconnect() async {
        await underlyingDevice.disconnect()
    }

    func startRecording() async throws -> AsyncStream<CombinedEEGSample> {
        try await underlyingDevice.startRecording()
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void) {
        underlyingDevice.setupDisconnectHandler(handler)
    }
}
