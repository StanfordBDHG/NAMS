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
    @MainActor var deviceConfiguration: DeviceConfiguration?
    @MainActor var samplingConfiguration: SamplingConfiguration?


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

            await MainActor.run {
                self.deviceConfiguration = configuration
            }
        } else if characteristic == Characteristic.biopotSamplingConfiguration {
            guard let configuration = SamplingConfiguration(from: &buffer) else {
                return
            }

            await MainActor.run {
                self.samplingConfiguration = configuration
            }
        } else if characteristic == Characteristic.biopotDataAcquisition {
            // TODO: depending on the accel status?
            guard let data = DataAcquisition11(from: &buffer) else {
                return
            }

            await MainActor.run {
                // TODO: how to publish the measurements!
            }
        } else {
            logger.warning("Data on \(characteristic.uuidString)@\(service.uuidString) was unexpected and not processed!")
        }
    }

    func readBiopot(characteristic: CBUUID) throws {
        try bluetooth.read(service: Service.biopot, characteristic: characteristic)
    }

    func enableRecording() async throws {
        try await setDataControl(false)

        try bluetooth.read(service: Service.biopot, characteristic: Characteristic.biopotDeviceConfiguration)

        try await setDataControl(true)
        try bluetooth.read(service: Service.biopot, characteristic: Characteristic.biopotSamplingConfiguration) // TODO: read after write
    }

    func setDataControl(_ enable: Bool) async throws {
        let control = DataControl(dataAcquisitionEnabled: enable)
        var buffer = ByteBuffer()
        control.encode(to: &buffer)

        try await bluetooth.write(&buffer, service: Service.biopot, characteristic: Characteristic.biopotDataControl)

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
