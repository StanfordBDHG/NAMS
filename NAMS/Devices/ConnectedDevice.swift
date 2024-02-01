//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth


enum ConnectedDevice {
    #if MUSE
    case muse(_ muse: MuseDevice)
    #endif
    case biopot(_ biopot: BiopotDevice)
    case mock(_ mock: MockDevice)

    @MainActor
    func connect() async {
        switch self {
            #if MUSE
        case let .muse(muse):
            muse.connect()
            #endif
        case let .biopot(biopot):
            await biopot.connect()
        case let .mock(mock):
            mock.connect()
        }
    }

    @MainActor
    func disconnect() async {
        switch self {
            #if MUSE
        case let .muse(muse):
            muse.disconnect()
            #endif
        case let .biopot(biopot):
            await biopot.disconnect()
        case let .mock(mock):
            mock.disconnect()
        }
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        switch self {
            #if MUSE
        case let .muse(muse):
            try await muse.startRecording(session)
            #endif
        case let .biopot(biopot):
            try await biopot.startRecording(session)
        case let .mock(mock):
            try await mock.startRecording(session)
        }
    }

    @MainActor
    func stopRecording() async throws {
        switch self {
            #if MUSE
        case let .muse(muse):
            try await muse.stopRecording()
            #endif
        case let .biopot(biopot):
            try await biopot.stopRecording()
        case let .mock(mock):
            try await mock.stopRecording()
        }
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping (ConnectedDevice) -> Void) {
        switch self {
            #if MUSE
        case let .muse(muse):
            muse.setupDisconnectHandler(handler)
            #endif
        case let .biopot(biopot):
            biopot.setupDisconnectHandler(handler)
        case let .mock(mock):
            mock.setupDisconnectHandler(handler)
        }
    }
}

extension ConnectedDevice: Hashable {}


extension ConnectedDevice: GenericBluetoothPeripheral {
    var label: String {
        switch self {
            #if MUSE
        case let .muse(muse):
            muse.label
            #endif
        case let .biopot(biopot):
            biopot.label
        case let .mock(mock):
            mock.label
        }
    }

    var state: PeripheralState {
        switch self {
            #if MUSE
        case let .muse(muse):
            muse.state
            #endif
        case let .biopot(biopot):
            biopot.state
        case let .mock(mock):
            mock.state
        }
    }
}
