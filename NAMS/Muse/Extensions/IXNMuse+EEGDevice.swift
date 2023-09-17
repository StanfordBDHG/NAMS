//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog


#if MUSE
extension IXNMuse: EEGDevice {
    var name: String {
        getName()
    }

    var macAddress: String {
        getMacAddress()
    }

    var model: String {
        getModel().description
    }

    var connectionState: ConnectionState {
        ConnectionState(from: getConnectionState())
    }

    var rssi: Double {
        getRssi()
    }

    var lastDiscoveredTime: Double {
        getLastDiscoveredTime()
    }

    func connect(state device: ConnectedDevice) -> DeviceConnectionListener {
        let listener = MuseConnectionListener(muse: self, device: device)
        listener.connect()
        return listener
    }
}

class MuseConnectionListener: DeviceConnectionListener, IXNMuseConnectionListener, IXNMuseDataListener { // TODO placement
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseConnectionListener")

    private unowned let muse: IXNMuse
    private let device: ConnectedDevice

    init(muse: IXNMuse, device: ConnectedDevice) {
        self.muse = muse
        self.device = device
    }

    func connect() {
        muse.register(self)

        // TODO support IXNMuseDataPacketTypeHsiPrecision (for how good it fits!)
        // TODO expose IXNMuseDataPacketTypeIsGood

        // TODO what other packets to register?
        // TODO threading?
        muse.register(self, type: .artifacts)
        muse.register(self, type: .eeg) // TODO frequencies guide https://www.learningeeg.com/terminology-and-waveforms
        muse.register(self, type: .battery)
        muse.register(self, type: .isGood)

        muse.runAsynchronously()
    }

    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        device.state = ConnectionState(from: packet.currentConnectionState)
        logger.debug("\(self.muse.getName()) state is now \(self.device.state.description)")

        // TODO check if version is already present earlier?

        // TODO check if can directly query battery percentage

        // TODO can we always query the serial number?

        switch device.state {
        case .connected:
            logger.debug("\(self.muse.getModel()) - \(self.muse.getName()): Connected. Versions: \(self.muse.getVersion()?.versionString ?? "NONE")")
        case .disconnected:
            device.remainingBatteryPercentage = nil
            device.wearingHeadband = false
            device.eyeBlink = false
            device.jawClench = false
            device.measurements = []
            // TODO reset isGood!

            self.muse.unregisterAllListeners()
            device.listener = nil
        default:
            break
        }
    }

    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        guard let packet else {
            return
        }

        switch packet.packetType() {
        case .alphaAbsolute, .eeg:
            // TODO picker for all the different hz: alpha, beta, ...

            // TODO might also be NaN for dropped packets!
            logger.debug("""
                         \(self.muse.getName()) data: \
                         \(packet.getEegChannelValue(.EEG1)) \
                         \(packet.getEegChannelValue(.EEG2)) \
                         \(packet.getEegChannelValue(.EEG3)) \
                         \(packet.getEegChannelValue(.EEG4))
                         """)

            if packet.packetType() == .eeg {
                // TODO maybe toggle collection only if the view is shown?
                device.measurements.append(EEGSeries(from: packet))
            }
        case .battery:
            device.remainingBatteryPercentage = packet.getBatteryValue(.chargePercentageRemaining)
            logger.debug("Remaining battery percentage: \(packet.getBatteryValue(.chargePercentageRemaining))")
        case .isGood:
            // TODO actually mark the measurements?
            device.isGood = (
                packet.getEegChannelValue(.EEG1) == 1.0,
                packet.getEegChannelValue(.EEG2) == 1.0,
                packet.getEegChannelValue(.EEG3) == 1.0,
                packet.getEegChannelValue(.EEG4) == 1.0
            )
        default:
            break
        }
    }

    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        if packet.headbandOn != device.wearingHeadband {
            logger.debug("Wearing headband: \(packet.headbandOn)")
            device.wearingHeadband = packet.headbandOn
        }

        if packet.blink != device.eyeBlink {
            device.eyeBlink = packet.blink
            if packet.blink {
                logger.debug("Detected eye blink")
            }
        }

        if packet.jawClench != device.jawClench {
            device.jawClench = packet.jawClench
            if packet.jawClench {
                logger.debug("Detected jaw clench")
            }
        }
    }
}

extension IXNMuseVersion { // TODO placement
    var versionString: String {
        // TODO bootloader version? running state?
        "firmware: \(getFirmwareVersion()) (\(getFirmwareBuildNumber()) - \(getFirmwareType())), hardware: \(getHardwareVersion()), protocol: \(getProtocolVersion()), bsp: \(getBspVersion())"
    }
}
#endif
