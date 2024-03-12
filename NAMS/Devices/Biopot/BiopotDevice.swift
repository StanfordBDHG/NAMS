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


/// The BioPot 3 bluetooth device.
///
/// If you need more information about bluetooth, you might find these resources helpful:
/// * https://en.wikipedia.org/wiki/Bluetooth_Low_Energy#Software_model
/// * https://www.bluetooth.com/blog/a-developers-guide-to-bluetooth
/// * https://devzone.nordicsemi.com/guides/short-range-guides/b/bluetooth-low-energy/posts/ble-characteristics-a-beginners-tutorial
class BiopotDevice: BluetoothDevice, Identifiable, SomeConnectedDevice {    
    private let logger = Logger(subsystem: "edu.stanford.nams", category: "BiopotDevice")

    @DeviceState(\.id)
    var id
    @DeviceState(\.state)
    var state
    @DeviceState(\.name)
    var name

    @DeviceAction(\.connect)
    fileprivate var _connect
    @DeviceAction(\.disconnect)
    fileprivate var _disconnect


    @Service var deviceInformation = DeviceInformationService()
    @Service var service = BiopotService() // TODO: make private and direct accesses?

    @MainActor private var disconnectHandler: (@MainActor (ConnectedDevice) -> Void)?


    var equipmentCode: String {
        "SML_BIO_\(service.deviceConfiguration?.serialNumber ?? 0)"
    }

    var signalDescription: [Signal]? {
        guard let samplingConfiguration = service.samplingConfiguration else {
            return nil
        }


        // format according to EDF+/BDF+ spec
        var prefilter = "HP:\(samplingConfiguration.highPassFilter.edfString)"
        if let lowPass = samplingConfiguration.softwareLowPassFilter.edfString {
            prefilter += " LP:\(lowPass)"
        }

        return [EEGLocation.lme, .tp10, .af8, .fp2, .fpz, .fp1, .af7, .mm].map { location in
            Signal(
                label: .eeg(location: location, prefix: .micro),
                transducerType: "EEG Electrode Sensor", // TODO: add num postfix, (or paper-based vs. headband?)
                prefiltering: prefilter,
                sampleCount: Int(samplingConfiguration.hardwareSamplingRate),
                physicalMinimum: -20_000,
                physicalMaximum: 20_0000,
                digitalMinimum: -8_388_608,
                digitalMaximum: 8_388_607
            )
        }
    }

    var recordDuration: Int {
        1
    }


    required init() {
        $state
            .onChange(perform: handleChange)
    }

    func connect() async {
        await self._connect()
    }

    func disconnect() async {
        await self._disconnect()
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void) {
        self.disconnectHandler = handler
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

    func prepareRecording() async throws {
        logger.debug("Preparing to record for biopot \(self.name ?? "")")
        try await service.prepareRecording()
    }

    func startRecording(_ session: EEGRecordingSession) async throws {
        try await service.startRecording(session)
    }

    func stopRecording() async throws {
        try await service.stopRecording()
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

        biopot.$_connect.inject { @MainActor [weak biopot] in
            biopot?.$state.inject(.connecting)
            biopot?.handleChange(of: .connecting)

            try? await Task.sleep(for: .seconds(1))

            biopot?.$state.inject(.connected)
            biopot?.handleChange(of: .connected)
        }

        biopot.$_disconnect.inject { @MainActor [weak biopot] in
            biopot?.$state.inject(.disconnected)
            biopot?.handleChange(of: .disconnected)
        }

        return biopot
    }
}
