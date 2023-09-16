//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreBluetooth


class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private let bluetoothManager: CBCentralManager
    private let dispatchQueue: DispatchQueue

    @Published private(set) var bluetoothState: CBManagerState

    override init() {
        // TODO shall we introduce an onboarding step for bluetooth?
        // We use a separate dispatch queue, be aware that all delegate calls are not getting on the main thread.
        // So make sure to interact with @Published properties only via the main thread
        self.dispatchQueue = DispatchQueue(label: "CBCentralManager")
        self.bluetoothManager = CBCentralManager(delegate: nil, queue: dispatchQueue)
        self.bluetoothState = bluetoothManager.state

        super.init()

        // CBCentralManager declares the delegate as weak
        self.bluetoothManager.delegate = self // cannot use self before super.init()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            self.bluetoothState = central.state
        }
    }
}
