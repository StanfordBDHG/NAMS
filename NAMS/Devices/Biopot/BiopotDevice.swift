//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import NIOCore
import OSLog
import Spezi
import SpeziBluetooth
import class CoreBluetooth.CBUUID


class BiopotService: BluetoothService {
    @Characteristic(id: .biopotDeviceInfoCharacteristic, notify: true)
    var deviceInfo: DeviceInformation?

    @Characteristic(id: .biopotDeviceConfigurationCharacteristic, notify: true)
    var deviceConfiguration: DeviceConfiguration?
    @Characteristic(id: .biopotSamplingConfigurationCharacteristic)
    var samplingConfiguration: SamplingConfiguration?
    @Characteristic(id: .biopotDataControlCharacteristic)
    var dataControl: DataControl?
    @Characteristic(id: .biopotImpedanceMeasurementCharacteristic)
    var impedanceMeasurement: ImpedanceMeasurement?

    @Characteristic(id: .biopotDataAcquisitionCharacteristic)
    var dataAcquisition: Data? // either `DataAcquisition10` or `DataAcquisition11` depending on the configuration.

    init() {}
}


/// The BioPot 3 bluetooth device.
///
/// If you need more information about bluetooth, you might find these resources helpful:
/// * https://en.wikipedia.org/wiki/Bluetooth_Low_Energy#Software_model
/// * https://www.bluetooth.com/blog/a-developers-guide-to-bluetooth
/// * https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial
class BiopotDevice: BluetoothDevice, Identifiable {
    private let logger = Logger(subsystem: "edu.stanford.nams", category: "BiopotDevice")

    @DeviceState(\.id)
    var id
    @DeviceState(\.state)
    var state // TODO: state update doesn't really work well (sometimes stale!)
    @DeviceState(\.name)
    var name

    @DeviceAction(\.connect)
    var connect
    @DeviceAction(\.disconnect)
    var disconnect

    var connected: Bool { // TODO: remove?
        state == .connected
    }


    @Service(id: .deviceInformationService)
    var deviceInformation = DeviceInformationService() // TODO: make sure we read once we are connected!
    @Service(id: .biopotService) // TODO: have the service self-contained by having the id in there, allows type based discovery criteria
    var service = BiopotService()

    @MainActor private var recordingSession: EEGRecordingSession?
    @MainActor private var startDate: Date?

    required init() {
        service.$dataAcquisition
            .onChange(perform: handleDataAcquisition)
        $state.onChange(perform: handleChange)
    }

    private func handleChange(of state: PeripheralState) {
        if case .connected = state {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500)) // TODO: better timing?
                logger.debug("Querying device information!")
                do {
                    try await deviceInformation.retrieveDeviceInformation()
                } catch {
                    logger.error("Failed to retrieve device information: \(error)")
                }
            }
        }
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        recordingSession = session
        try await self.enableRecording()
    }

    @MainActor
    func stopRecording() async throws {
        try await service.$dataControl.write(false)
        startDate = nil
        recordingSession = nil
    }

    @MainActor
    func enableRecording() async throws {
        do {
            try await service.$dataControl.write(false)

            // make sure the value is up to date
            _ = try await service.$deviceConfiguration.read()

            startDate = .now

            try await service.$dataControl.write(true)
            _ = try await service.$samplingConfiguration.read()
        } catch {
            logger.error("Failed to enable Biopot recording: \(error)")
            throw error
        }
    }

    private func handleDataAcquisition(data: Data) {
        guard let deviceConfiguration = service.deviceConfiguration else {
            logger.warning("Received data acquisition without having device configuration ready!")
            return
        }

        guard deviceConfiguration.dataSize == 24
                && deviceConfiguration.channelCount == 8 else {
            logger.error("Unable to process data acquisition. Unexpected configuration: \(String(describing: deviceConfiguration))")
            return
        }

        let acquisition: DataAcquisition?
        if case .off = deviceConfiguration.accelerometerStatus {
            acquisition = DataAcquisition10(data: data)
        } else {
            acquisition = DataAcquisition11(data: data)
        }

        guard let acquisition else {
            return
        }

        Task { @MainActor in
            guard let recordingSession else {
                return
            }

            let baseDate = startDate ?? .now

            let series: [EEGSeries] = acquisition.samples.map { sample in
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
                let timestamp = baseDate.addingTimeInterval(Double(acquisition.timestamps) / 1000.0)
                return EEGSeries(timestamp: timestamp, readings: readings)
            }

            recordingSession.append(series: series, for: .all)
        }
    }
}


extension BiopotDevice: Hashable {
    static func == (lhs: BiopotDevice, rhs: BiopotDevice) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}


extension BiopotDevice: GenericBluetoothPeripheral {
    var label: String {
        // TODO: default naming?
        name ?? "unknown device" // TODO: maybe strip out the mac address?
    }
    // TODO: have dedicated accessibility label?
}


// TODO: move that
extension CBUUID {
    static let biopotService = CBUUID(string: "FFF0")

    // Access properties: R: read, W: write, N: notify
    // naming is currently guess work

    /// Characteristic 1, as per the manual. RWN.
    static let biopotDeviceConfigurationCharacteristic = CBUUID(string: "FFF1")
    /// Characteristic 2, as per the manual. RW.
    static let biopotDataControlCharacteristic = CBUUID(string: "FFF2")
    /// Characteristic 3, as per the manual. RW.
    static let biopotImpedanceMeasurementCharacteristic = CBUUID(string: "FFF3")
    /// Characteristic 4, as per the manual. RN.
    static let biopotDataAcquisitionCharacteristic = CBUUID(string: "FFF4")
    /// Characteristic 5, as per the manual. RW.
    static let biopotSamplingConfigurationCharacteristic = CBUUID(string: "FFF5")
    // swiftlint:disable:previous identifier_name
    /// Characteristic 6, as per the manual. RN.
    static let biopotDeviceInfoCharacteristic = CBUUID(string: "FFF6")
}
