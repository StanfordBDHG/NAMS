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
import OSLog
import Spezi
import SpeziBluetooth


/// Model for the BioPot 3 device.
///
/// If you need more information about bluetooth, you might find these resources helpful:
/// * https://en.wikipedia.org/wiki/Bluetooth_Low_Energy#Software_model
/// * https://www.bluetooth.com/blog/a-developers-guide-to-bluetooth
/// * https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial
@Observable
class BiopotDevice: Module, EnvironmentAccessible, BluetoothMessageHandler, DefaultInitializable {
    private let logger = Logger(subsystem: "edu.stanford.nams", category: "BiopotDevice")

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
            logger.warning("Received data for unknown service: \(service)")
            return
        }

        logger.warning("Received data for biopot on service \(service.uuidString) for characteristic \(characteristic.uuidString): \(data.hexString())")

        var buffer = ByteBuffer(data: data)

        if characteristic == Characteristic.biopotDeviceInfo {
            guard let information = DeviceInformation(from: &buffer) else {
                return
            }

            await MainActor.run {
                self.deviceInfo = information
            }
        } else if characteristic == Characteristic.biopotDeviceConfiguration {
            guard let configuration = DeviceConfiguration(from: &buffer) else {
                return
            }

            logger.debug("Received configuration data: \("\(configuration)")")
        } else {
            logger.warning("Data on \(characteristic.uuidString)@\(service.uuidString) was unexpected and not processed!")
        }
    }

    func readBiopot(characteristic: CBUUID) throws {
        try bluetooth.read(service: Service.biopot, characteristic: characteristic)
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
        static let biopotImpedanceMeasurement = CBUUID(string: "0000FFF3-0000-1000-8000-00805F9B34FB")
        /// Characteristic 4, as per the manual. RN.
        static let biopotDataAcquisition = CBUUID(string: "0000FFF4-0000-1000-8000-00805F9B34FB")
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
