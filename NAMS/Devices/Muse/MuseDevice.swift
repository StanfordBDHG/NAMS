//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import EDFFormat
import Foundation
import OSLog
import SpeziBluetooth


#if MUSE
@Observable
class MuseDevice: Identifiable, SomeConnectedDevice {
    /// List of data packets we are registering to.
    private static let packetTypes: [IXNMuseDataPacketType] = [
        .artifacts,
        .battery,
        .isGood,

        .eeg, // enables collection of raw data

        .hsiPrecision
    ]

    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDevice")

    private let muse: IXNMuse
    private var connectionListener: ConnectionListener?
    private var dataListener: DataListener?

    var connectionState: ConnectionState
    /// The device information, preset if device is connected
    var deviceInformation: MuseDeviceInformation?

    /// The currently associated recording session.
    private var recordingSession: EEGRecordingSession?
    @MainActor private var disconnectHandler: ((ConnectedDevice) -> Void)?

    var name: String {
        muse.getName().replacingOccurrences(of: "Muse-", with: "")
    }

    var id: String {
        muse.getMacAddress()
    }

    var model: String {
        muse.getModel().description
    }

    var label: String {
        "\(model) - \(name)"
    }

    var rssi: Double {
        muse.getRssi()
    }

    var lastDiscoveredTime: Double? {
        let time = muse.getLastDiscoveredTime()
        guard !time.isNaN else {
            return nil
        }
        return time
    }

    var underlyingDevice: IXNMuse {
        muse
    }

    var equipmentCode: String {
        "MUSE_\(deviceInformation?.serialNumber ?? "0")" // TODO: update model description
    }

    var signalDescription: [Signal]? { // swiftlint:disable:this discouraged_optional_collection
        guard let deviceInformation else {
            return nil // TODO: or make it throwing?
        }

        /*
         // format according to EDF+/BDF+ spec
         var prefilter = "HP:\(samplingConfiguration.highPassFilter.edfString)"
         if let lowPass = samplingConfiguration.softwareLowPassFilter.edfString {
         prefilter += " LP:\(lowPass)"
         TODO: add Notch filter!
         }
         */

        return [EEGLocation.tp9, .af7, .af8, .tp10].map { location in
            Signal(
                label: .eeg(location: location, prefix: .micro),
                transducerType: "EEG Electrode Sensor", // TODO: add num postfix, (or paper-based vs. headband?)
                // TODO: prefiltering: prefilter,
                sampleCount: deviceInformation.sampleRate,
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

    init(_ muse: IXNMuse) {
        self.muse = muse
        self.connectionState = ConnectionState(from: muse.getConnectionState())

        self.connectionListener = ConnectionListener(device: self)
        self.muse.setNumConnectTries(0)
    }

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void) {
        self.disconnectHandler = handler
    }

    func connect() {
        dataListener = DataListener(device: self)

        // set the preset manually for now
        switch muse.getModel() {
        case .mu01, .mu02:
            break
        case .mu03, .mu04, .mu05:
            muse.setPreset(.preset53)
        @unknown default:
            break
        }

        muse.runAsynchronously()
    }

    func disconnect() {
        muse.disconnect()
    }

    func prepareRecording() async throws {
        // TODO: implement?
    }

    @MainActor
    func startRecording(_ session: EEGRecordingSession) async throws {
        self.recordingSession = session
    }

    @MainActor
    func stopRecording() async throws {
        self.recordingSession = nil
    }


    @MainActor
    private func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse) {
        connectionState = ConnectionState(from: packet.currentConnectionState)
        logger.debug("\(self.name) state is now \(self.connectionState.description)")

        switch connectionState {
        case .connected:
            handleDeviceConnected()
        case .disconnected:
            deviceInformation = nil
            connectionListener = nil
            if let disconnectHandler {
                self.disconnectHandler = nil
                disconnectHandler(.muse(self))
            }
        default:
            break
        }
    }

    private func handleDeviceConnected() {
        guard let version = muse.getVersion(),
              let configuration = muse.getConfiguration() else {
            logger.warning("\(self.label): Failed to retrieve device information even though device was reported as connected!")
            return
        }

        logger.debug("\(self.label): Connected. Versions: \(version.versionString); Configuration: \(configuration.configurationString)")

        self.deviceInformation = MuseDeviceInformation(
            serialNumber: configuration.getSerialNumber(),
            firmwareVersion: version.getFirmwareVersion(),
            hardwareVersion: version.getHardwareVersion(),
            sampleRate: Int(configuration.getOutputFrequency()),
            notchFilter: configuration.getNotchFilter(),
            afeGain: Int(configuration.getAfeGain()),
            remainingBatteryPercentage: configuration.getBatteryPercentRemaining()
        )
    }


    @EEGProcessing
    private func receive(_ packet: IXNMuseDataPacket, muse: IXNMuse) { // swiftlint:disable:this cyclomatic_complexity
        guard let deviceInformation else {
            return
        }

        switch packet.packetType() {
        case .hsiPrecision:
            let fit = HeadbandFit(from: packet)
            if deviceInformation.fit != fit {
                deviceInformation.fit = fit
            }
        case .eeg:
            recordingSession?.append(CombinedEEGSample(from: packet))
        case .battery:
            deviceInformation.remainingBatteryPercentage = packet.getBatteryValue(.chargePercentageRemaining)
        case .isGood:
            deviceInformation.isGood = (
                packet.getEegChannelValue(.EEG1) == 1.0,
                packet.getEegChannelValue(.EEG2) == 1.0,
                packet.getEegChannelValue(.EEG3) == 1.0,
                packet.getEegChannelValue(.EEG4) == 1.0
            )
        default:
            break
        }
    }

    @MainActor
    private func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse) {
        if packet.headbandOn != deviceInformation?.wearingHeadband {
            logger.debug("Wearing headband: \(packet.headbandOn)")
            deviceInformation?.wearingHeadband = packet.headbandOn
        }

        if packet.blink != deviceInformation?.eyeBlink {
            deviceInformation?.eyeBlink = packet.blink
            if packet.blink {
                logger.debug("Detected eye blink")
            }
        }

        if packet.jawClench != deviceInformation?.jawClench {
            deviceInformation?.jawClench = packet.jawClench
            if packet.jawClench {
                logger.debug("Detected jaw clench")
            }
        }
    }

    deinit {
        if dataListener != nil {
            disconnect()
            self.dataListener = nil
        }
        connectionListener = nil
    }
}

extension MuseDevice: Hashable {
    public static func == (lhs: MuseDevice, rhs: MuseDevice) -> Bool {
        lhs.muse == rhs.muse
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(muse)
    }
}

extension MuseDevice: GenericBluetoothPeripheral {
    var state: PeripheralState {
        switch connectionState {
        case .disconnected, .unknown:
            return .disconnected
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        case .interventionRequired:
            return .connected
        }
    }
}


extension MuseDevice {
    private class ConnectionListener: IXNMuseConnectionListener {
        private weak var device: MuseDevice?

        init(device: MuseDevice) {
            self.device = device
            device.muse.register(self)
        }

        func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
            guard let device, let muse else {
                return
            }
            Task { @MainActor in
                device.receive(packet, muse: muse)
            }
        }


        deinit {
            guard let device else {
                preconditionFailure("MuseDevice was deinitialized before \(Self.self) was deinitialized.")
            }
            device.muse.unregisterConnectionListener(self)
        }
    }
}


extension MuseDevice {
    private class DataListener: IXNMuseDataListener {
        private weak var device: MuseDevice?

        init(device: MuseDevice) {
            self.device = device

            for type in MuseDevice.packetTypes {
                device.muse.register(self, type: type)
            }
        }

        func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
            guard let device, let packet, let muse else {
                return
            }
            Task { @EEGProcessing in
                device.receive(packet, muse: muse)
            }
        }

        func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
            guard let device, let muse else {
                return
            }
            Task { @MainActor in
                device.receive(packet, muse: muse)
            }
        }

        deinit {
            guard let device else {
                preconditionFailure("MuseDevice was deinitialized before \(Self.self) was deinitialized.")
            }
            for type in MuseDevice.packetTypes {
                device.muse.register(self, type: type)
            }
        }
    }
}
#endif
