//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import SpeziBluetooth


@Observable
class MuseDeviceInformation {
    let serialNumber: String
    let firmwareVersion: String
    let hardwareVersion: String

    /// Remaining battery percentage in percent [0.0;100.0]
    var remainingBatteryPercentage: Double?

    // artifacts muse supports
    var wearingHeadband = false
    var eyeBlink = false
    var jawClench = false

    /// Determines if the last second of data is considered good
    var isGood: (Bool, Bool, Bool, Bool) = (false, false, false, false) // swiftlint:disable:this large_tuple
    /// The current fit of the headband
    var fit: HeadbandFit?

    init(
        serialNumber: String,
        firmwareVersion: String,
        hardwareVersion: String,
        remainingBatteryPercentage: Double? = nil,
        wearingHeadband: Bool = false,
        fit: HeadbandFit? = nil
    ) {
        self.serialNumber = serialNumber
        self.firmwareVersion = firmwareVersion
        self.hardwareVersion = hardwareVersion
        self.remainingBatteryPercentage = remainingBatteryPercentage
        self.wearingHeadband = wearingHeadband
        self.fit = fit
    }
}

#if MUSE
@Observable
class MuseDevice: Identifiable {
    /// List of data packets we are registering to.
    private static let packetTypes: [IXNMuseDataPacketType] = [
        .artifacts,
        .battery,
        .isGood,

        // Might want to read https://www.learningeeg.com/terminology-and-waveforms for a short intro into EEG frequency ranges
        .thetaAbsolute, // 4-8 Hz
        .alphaAbsolute, // 8-16 Hz
        .betaAbsolute, // 16-32 Hz
        .gammaAbsolute, // 32-64 Hz
        // .eeg, // enables collection of raw data

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
    @MainActor private var recordingSession: EEGRecordingSession?

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

    var lastDiscoveredTime: Double {
        muse.getLastDiscoveredTime()
    }

    var underlyingDevice: IXNMuse {
        muse
    }

    init(_ muse: IXNMuse) {
        self.muse = muse
        self.connectionState = ConnectionState(from: muse.getConnectionState())

        self.connectionListener = ConnectionListener(device: self)
        self.muse.setNumConnectTries(0)
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
            remainingBatteryPercentage: configuration.getBatteryPercentRemaining()
        )
    }


    @MainActor
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
            recordingSession?.append(series: EEGSeries(from: packet), for: .all)
        case .thetaAbsolute:
            recordingSession?.append(series: EEGSeries(from: packet), for: .theta)
        case .alphaAbsolute:
            recordingSession?.append(series: EEGSeries(from: packet), for: .alpha)
        case .betaAbsolute:
            recordingSession?.append(series: EEGSeries(from: packet), for: .beta)
        case .gammaAbsolute:
            recordingSession?.append(series: EEGSeries(from: packet), for: .gamma)
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
            Task { @MainActor in
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
