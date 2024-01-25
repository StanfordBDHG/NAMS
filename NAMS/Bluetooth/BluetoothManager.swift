//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreBluetooth
import OSLog


@Observable
class BluetoothManager: NSObject, CBCentralManagerDelegate {
    private let logger = Logger(subsystem: "edu.standford.nams", category: "BluetoothManager")

    private let bluetoothManager: CBCentralManager
    private let dispatchQueue: DispatchQueue

    private(set) var bluetoothState: CBManagerState

    override init() {
        // We use a separate dispatch queue, be aware that all delegate calls are not getting on the main thread.
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
            logger.debug("BluetoothState is now \(central.state.rawValue)")
        }
    }
}
