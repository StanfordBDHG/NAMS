//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import OSLog
import Spezi
import SpeziBluetooth
import class CoreBluetooth.CBUUID
import SwiftUI


class BiopotService: BluetoothService {
    @Characteristic(id: .biopotDeviceInfoCharacteristic, notify: true)
    var deviceInfo: DeviceInformation?

    @Characteristic(id: .biopotDeviceConfigurationCharacteristic, notify: true)
    var deviceConfiguration: DeviceConfiguration?
    @Characteristic(id: .biopotSamplingConfigurationCharacteristic)
    var samplingConfiguration: SamplingConfiguration?
    @Characteristic(id: .biopotDataControlCharacteristic)
    var dataControl: DataControl?

    @Characteristic(id: .biopotDataAcquisitionCharacteristic)
    var dataAcquisition: Data? // TODO: ByteBuffer doesn't really make sense to by ByteDecodable?
    @Characteristic(id: .biopotImpedanceMeasurementCharacteristic)
    var impedanceMeasurement: Data? // TODO: find a type for it!

    init() {}
}


/// The BioPot 3 bluetooth device.
///
/// If you need more information about bluetooth, you might find these resources helpful:
/// * https://en.wikipedia.org/wiki/Bluetooth_Low_Energy#Software_model
/// * https://www.bluetooth.com/blog/a-developers-guide-to-bluetooth
/// * https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial
class BiopotDevice: BluetoothDevice {
    private let logger = Logger(subsystem: "edu.stanford.nams", category: "BiopotDevice")

    @DeviceState(\.state)
    var state

    var connected: Bool {
        state == .connected
    }

    // TODO: add a device information service!

    @Service(id: .biopotService)
    var service = BiopotService()

    @MainActor var startDate: Date?

    @Binding @ObservationIgnored private var recordingSession: EEGRecordingSession?

    required init() {
        self._recordingSession = .constant(nil)
    }

    func associate(_ model: EEGViewModel) { // TODO: handle this everytime it gets newly created?
        self._recordingSession = model.recordingSessionBinding
    }

    func enableRecording() async {
        do {
            try await setDataControl(false)

            _ = try await service.$deviceConfiguration.read() // TODO: use the result?

            await MainActor.run {
                startDate = .now
            }
            try await setDataControl(true)
            _ = try await service.$samplingConfiguration.read()
        } catch {
            logger.error("Failed to enable Biopot recording: \(error)")
        }
    }

    func setDataControl(_ enable: Bool) async throws {
        let control = DataControl(dataAcquisitionEnabled: enable)
        _ = try await service.$dataControl.write(control) // TODO: what's the response here?
    }

    // TODO: actually call this handler on change of @Characteristic!
    private func handleDataAcquisition(buffer: inout ByteBuffer) async {
        guard let deviceConfiguration = service.deviceConfiguration else {
            logger.warning("Received data acquisition without having device configuration ready!")
            return
        }

        guard deviceConfiguration.dataSize == 24
                && deviceConfiguration.channelCount == 8 else {
            logger.error("Unable to process data acquisition. Unexpected configuration: \(String(describing: deviceConfiguration))")
            return
        }

        let data: DataAcquisition?
        if case .off = deviceConfiguration.accelerometerStatus {
            data = DataAcquisition10(from: &buffer)
        } else {
            data = DataAcquisition11(from: &buffer)
        }

        guard let data else {
            return
        }

        await MainActor.run {
            guard let recordingSession else {
                return
            }

            let baseDate = startDate ?? .now

            let series: [EEGSeries] = data.samples.map { sample in
                var readings: [EEGReading] = []
                readings.reserveCapacity(8)

                for index in 1...sample.channels.count {
                    guard let channel = EEGChannel(biopotNum: index) else {
                        continue
                    }

                    readings.append(EEGReading(channel: channel, value: Double(sample.channels[index - 1].sample)))
                }


                // We currently register all samples within a packet at the same timestamp. We might need to research
                // how each sample within a packet is evenly distributed.
                let timestamp = baseDate.addingTimeInterval(Double(data.timestamps) / 1000.0)
                return EEGSeries(timestamp: timestamp, readings: readings)
            }

            recordingSession.measurements[.all, default: []].append(contentsOf: series)
        }
    }
}


extension CBUUID {
    static let biopotService = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")

    // Access properties: R: read, W: write, N: notify
    // naming is currently guess work

    /// Characteristic 1, as per the manual. RWN.
    static let biopotDeviceConfigurationCharacteristic = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    /// Characteristic 2, as per the manual. RW.
    static let biopotDataControlCharacteristic = CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB")
    /// Characteristic 3, as per the manual. RW.
    static let biopotImpedanceMeasurementCharacteristic = CBUUID(string: "0000FFF3-0000-1000-8000-00805F9B34FB")
    /// Characteristic 4, as per the manual. RN.
    static let biopotDataAcquisitionCharacteristic = CBUUID(string: "0000FFF4-0000-1000-8000-00805F9B34FB")
    /// Characteristic 5, as per the manual. RW.
    static let biopotSamplingConfigurationCharacteristic = CBUUID(string: "0000FFF5-0000-1000-8000-00805F9B34FB")
    /// Characteristic 6, as per the manual. RN.
    static let biopotDeviceInfoCharacteristic = CBUUID(string: "0000FFF6-0000-1000-8000-00805F9B34FB")
}


extension Data {
    func hexString() -> String { // TODO: is this part of XCTBluetooth? or just Bluetooth?
        map { String(format: "%02hhx", $0) }.joined()
    }
}
