//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import BluetoothViews
import EDFFormat
import OSLog
import Spezi
@_spi(TestingSupport)
import SpeziBluetooth
import class CoreBluetooth.CBUUID


/// The primary Biopot service
///
/// - Note: Notation within the docs: Access properties: R: read, W: write, N: notify.
///     Naming is currently guess work.
class BiopotService: BluetoothService {
    static let id = CBUUID(string: "FFF0")

    /// Characteristic 6, as per the manual. RN.
    @Characteristic(id: "FFF6", notify: true)
    var deviceInfo: DeviceInformation?

    /// Characteristic 1, as per the manual. RW.
    /// Note: Even though Bluetooth reports this as notify it isn't!!
    @Characteristic(id: "FFF1")
    var deviceConfiguration: DeviceConfiguration?
    /// Characteristic 5, as per the manual. RW.
    @Characteristic(id: "FFF5")
    var samplingConfiguration: SamplingConfiguration?
    /// Characteristic 2, as per the manual. RW.
    @Characteristic(id: "FFF2")
    var dataControl: DataControl?
    /// Characteristic 3, as per the manual. RW.
    @Characteristic(id: "FFF3")
    var impedanceMeasurement: ImpedanceMeasurement?

    /// Characteristic 4, as per the manual. RN.
    @Characteristic(id: "FFF4", notify: true)
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
    var state
    @DeviceState(\.name)
    var name

    @DeviceAction(\.connect)
    var connect
    @DeviceAction(\.disconnect)
    var disconnect


    @Service var deviceInformation = DeviceInformationService()
    @Service var service = BiopotService()

    @MainActor private var recordingSession: EEGRecordingSession?
    @MainActor private var startDate: Date?
    @MainActor private var disconnectHandler: ((ConnectedDevice) -> Void)?

    required init() {
        service.$dataAcquisition
            .onChange(perform: handleDataAcquisition)
        $state
            .onChange(perform: handleChange)
    }

    @MainActor
    private func handleChange(of state: PeripheralState) {
        logger.debug("Biopot device is now \(state)")

        if state == .disconnected || state == .disconnecting {
            if let disconnectHandler {
                self.disconnectHandler = nil
                disconnectHandler(.biopot(self))
            }
        }
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping (ConnectedDevice) -> Void) {
        self.disconnectHandler = handler
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        recordingSession = session
        try await self.enableRecording()
    }

    @MainActor
    func stopRecording() async throws {
        try await service.$dataControl.write(.paused)
        startDate = nil
        recordingSession = nil
    }

    @MainActor
    private func enableRecording() async throws {
        do {
            try await service.$dataControl.write(.paused)

            // TODO: what does biopot app do
            //  - .RequestMtuAsync(251)
            //  - read device configuration (e.g., channel count)


            // make sure the value is up to date
            _ = try await service.$deviceConfiguration.read() // TODO: check their on subscribe method
            _ = try await service.$samplingConfiguration.read()

            // TODO: we need channel count and sampling rate right?

            // TODO: make sure we always have the latest sampling rate!

            startDate = .now

            try await service.$dataControl.write(.started)
        } catch {
            logger.error("Failed to enable Biopot recording: \(error)")
            throw error
        }
    }

    func handleDataAcquisition(data: Data) {
        guard let deviceConfiguration = service.deviceConfiguration else {
            logger.debug("Received data acquisition without having device configuration ready!")
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

        // TODO: record the elapsed time between two consecutive data packets (first one is zero!)

        guard let acquisition else {
            logger.error("Failed to decode data acquisition: \(data.hexString())")
            return
        }

        Task { @MainActor in
            guard let recordingSession else {
                return
            }

            let baseDate = self.startDate ?? .now

            let series: [EEGSeries] = acquisition.samples.map { sample in
                var readings: [EEGReading] = []
                readings.reserveCapacity(8)

                for index in 1...sample.channels.count {
                    guard let location = EEGLocation(biopotNum: index) else {
                        continue
                    }

                    readings.append(EEGReading(location: location, value: Double(sample.channels[index - 1].value)))
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
        name ?? "unknown device"
    }

    var accessibilityLabel: String {
        let label = label
        if label.starts(with: "SML BIO") {
            return "SensoMedical Biopot"
        } else {
            return label
        }
    }
}


extension BiopotDevice {
    static func createMock(serial: String = "0xAABBCCDD", state: PeripheralState = .disconnected) -> BiopotDevice {
        let biopot = BiopotDevice()
        biopot.service.$deviceInfo.inject(DeviceInformation(
            syncRatio: 0,
            syncMode: false,
            memoryWriteNumber: 0,
            memoryEraseMode: false,
            batteryLevel: 75,
            temperatureValue: 23,
            batteryCharging: true
        ))
        biopot.deviceInformation.$firmwareRevision.inject("1.2.3")
        biopot.deviceInformation.$serialNumber.inject(serial)
        biopot.deviceInformation.$hardwareRevision.inject("3.1")

        biopot.$id.inject(UUID())
        biopot.$name.inject("SML BIO \(serial)")
        biopot.$state.inject(state)

        biopot.$connect.inject { @MainActor [weak biopot] in
            biopot?.$state.inject(.connecting)
            biopot?.handleChange(of: .connecting)

            try? await Task.sleep(for: .seconds(1))

            biopot?.$state.inject(.connected)
            biopot?.handleChange(of: .connected)
        }

        biopot.$disconnect.inject { @MainActor [weak biopot] in
            biopot?.$state.inject(.disconnected)
            biopot?.handleChange(of: .disconnected)
        }

        return biopot
    }
}
