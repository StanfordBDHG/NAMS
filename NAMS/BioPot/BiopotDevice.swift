//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation
import NIOCore
import Spezi
import SpeziBluetooth


// TODO: should we recommend a read like https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial

@Observable
class BiopotDevice: Module, EnvironmentAccessible, BluetoothMessageHandler, DefaultInitializable {
    @ObservationIgnored @Dependency private var bluetooth: Bluetooth

    var bluetoothState: BluetoothState {
        bluetooth.state
    }

    @MainActor var deviceInfo: DeviceInformation?

    required init() {}

    func configure() {
        bluetooth.add(messageHandler: self)
    }

    func recieve(_ data: Data, service: CBUUID, characteristic: CBUUID) async {
        guard service == Service.biopot else {
            print("Received data for unknown service: \(service)")
            return
        }

        var buffer = ByteBuffer(data: data)

        if characteristic == Characteristic.biopotDeviceInfo {
            guard let information = DeviceInformation(from: &buffer) else {
                return
            }

            Task { @MainActor in
                self.deviceInfo = information
            }
        } else if characteristic == Characteristic.biopotDeviceConfiguration {
            guard let configuration = DeviceConfiguration(from: &buffer) else {
                return
            }

            print("Received data for \(service.uuidString) on \(characteristic.uuidString): \(configuration)")
        } else {
            print("Received data for unknown biopot characteristic: \(characteristic)")
        }
    }
}

extension BiopotDevice {
    enum Service {
        static let biopot = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    }
}

extension BiopotDevice {
    /// Characteristic definitions with access properties.
    ///
    /// Access properties: R: read, W: write, N: notify
    enum Characteristic { // naming is currently guess work
        /// Characteristic 1, as per the manual. RWN.
        static let biopotDeviceConfiguration = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
        /// Characteristic 2, as per the manual. RW.
        static let biopotDataControl = CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB")
        /// Characteristic 3, as per the manual. RW.
        static let biopotDataAcquisition = CBUUID(string: "0000FFF3-0000-1000-8000-00805F9B34FB")
        /// Characteristic 4, as per the manual. RN.
        static let biopotDataStream = CBUUID(string: "0000FFF4-0000-1000-8000-00805F9B34FB")
        /// Characteristic 5, as per the manual. RW.
        static let biopotSamplingConfiguration = CBUUID(string: "0000FFF5-0000-1000-8000-00805F9B34FB")
        /// Characteristic 6, as per the manual. RN.
        static let biopotDeviceInfo = CBUUID(string: "0000FFF6-0000-1000-8000-00805F9B34FB")
    }
}


extension Data {
    func hexString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
