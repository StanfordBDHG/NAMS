//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation
import Spezi
import SpeziBluetooth


// TODO: should we recommend a read like https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial

class BiopotDevice: Component, ObservableObject, ObservableObjectProvider, BluetoothMessageHandler, DefaultInitializable {
    @Dependency private var bluetooth: Bluetooth

    private var bluetoothAnyCancellable: AnyCancellable?

    var bluetoothState: BluetoothState {
        bluetooth.state
    }

    @MainActor @Published var deviceInfo: DeviceInformation?

    required init() {}

    func configure() {
        bluetoothAnyCancellable = bluetooth
            .objectWillChange
            .receive(on: RunLoop.main)
            .sink {
                self.objectWillChange.send()
            }

        bluetooth.add(messageHandler: self)
    }

    // swiftlint:disable:next function_body_length
    func recieve(_ data: Data, service: CBUUID, characteristic: CBUUID) async {
        guard service == Service.biopot else {
            print("Received data for unknown service: \(service)")
            return
        }

        if characteristic == Characteristic.biopotDeviceInfo {
            let information = data.withUnsafeBytes { pointer in
                let syncRation = pointer.load(as: Double.self)
                let syncMode = pointer.load(fromByteOffset: 8, as: Bool.self)
                let memoryWriteNumber = pointer.loadUnaligned(fromByteOffset: 9, as: UInt16.self)
                let memoryEraseMode = pointer.load(fromByteOffset: 11, as: Bool.self)
                let batteryLevel = pointer.load(fromByteOffset: 12, as: UInt8.self)
                let temperatureValue = pointer.load(fromByteOffset: 13, as: UInt8.self)

                // documentation is wrong, this bit is flipped for some reason
                let batteryCharging = !pointer.load(fromByteOffset: 14, as: Bool.self)

                return DeviceInformation(
                    syncRation: syncRation,
                    syncMode: syncMode,
                    memoryWriteNumber: memoryWriteNumber,
                    memoryEraseMode: memoryEraseMode,
                    batteryLevel: batteryLevel,
                    temperatureValue: temperatureValue,
                    batteryCharging: batteryCharging
                )
            }

            Task { @MainActor in
                self.deviceInfo = information
            }
        } else if characteristic == Characteristic.biopotDeviceConfiguration {
            let configuration = data.withUnsafeBytes { pointer in
                // 5 bytes reserved
                let channelCount = pointer.load(fromByteOffset: 5, as: UInt8.self)
                let accelerometerStatus = pointer.load(fromByteOffset: 6, as: UInt8.self)
                let impedanceStatus = pointer.load(fromByteOffset: 7, as: Bool.self)
                let memoryStatus = pointer.load(fromByteOffset: 8, as: Bool.self)
                let samplesPerChannel = pointer.load(fromByteOffset: 9, as: UInt8.self)
                let dataSize = pointer.load(fromByteOffset: 10, as: UInt8.self)
                let syncEnabled = pointer.load(fromByteOffset: 11, as: Bool.self)

                let serialNumber = pointer[12...15] // TODO: verify that this is how it is done!
                    .map { element in
                        String(format: "%02hhx", element)
                    }
                    .joined()

                return DeviceConfiguration(
                    channelCount: channelCount,
                    accelerometerStatus: accelerometerStatus,
                    impedanceStatus: impedanceStatus,
                    memoryStatus: memoryStatus,
                    samplesPerChannel: samplesPerChannel,
                    dataSize: dataSize,
                    syncEnabled: syncEnabled,
                    serialNumber: serialNumber
                )
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
