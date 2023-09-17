//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog

enum EEGChannel: String { // TODO naming?
    case tp9 = "TP9"
    case af7 = "AF7"
    case af8 = "AF8"
    case tp10 = "TP10"

    var ixnEEG: IXNEeg {
        switch self {
        case .tp9:
            return .EEG1
        case .af7:
            return .EEG2
        case .af8:
            return .EEG3
        case .tp10:
            return .EEG4
        }
    }

    init(from eeg: IXNEeg) { // TODO do we need this mapping?
        switch eeg {
        case .EEG1:
            self = .tp9
        case .EEG2:
            self = .af7
        case .EEG3:
            self = .af8
        case .EEG4:
            self = .tp10
        default:
            fatalError("Unsupported EEG channel: \(eeg)") // TODO ?
        }
    }
}

struct EEGReading {
    let channel: EEGChannel
    /// Value in micro volts
    let value: Double

    init(from packet: IXNMuseDataPacket, _ channel: EEGChannel) {
        self.channel = channel
        self.value = packet.getEegChannelValue(channel.ixnEEG)
    }
}

struct EEGSeries: Identifiable {
    let id = UUID() // TODO time series?

    let timestamp: Date
    let readings: [EEGReading] // TODO should be an array of four!


    init(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType() == .eeg, "Unsupported packet type to parse eeg readings \(packet.packetType())") // TODO support all the other eeg packets!

        let epochMillis = packet.timestamp()

        self.timestamp = Date(timeIntervalSince1970: Double(epochMillis) * 0.001 * 0.001) // micro seconds -> seconds
        self.readings = [
            EEGReading(from: packet, .tp9),
            EEGReading(from: packet, .af7),
            EEGReading(from: packet, .af8),
            EEGReading(from: packet, .tp10)
        ]
    }


    func reading(for channel: EEGChannel) -> EEGReading {
        let index: Int = channel.ixnEEG.rawValue
        return readings[index]
    }
}


class ConnectedMuse: ObservableObject, IXNMuseConnectionListener, IXNMuseDataListener {
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDevice")

    let muse: IXNMuse

    @Published var state: IXNConnectionState = .unknown

    // artifacts muse supports
    @Published var wearingHeadband = false
    @Published var eyeBlink = false
    @Published var jawClench = false

    // swiftlint:disable:next large_tuple
    @Published var isGood: (Bool, Bool, Bool, Bool) = (false, false, false, false) // TODO type!

    /// Remaining battery percentage in percent [0.0;100.0]
    @Published var remainingBatteryPercentage: Double?

    @Published var measurements: [EEGSeries] = []

    init(muse: IXNMuse) {
        self.muse = muse
    }

    func connect() {
        // TODO is this a cyclic dependency now?
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
        self.state = packet.currentConnectionState
        logger.debug("\(self.muse.getName()) state is now \(self.state.description)")

        // TODO check if version is already present earlier?

        switch state {
        case .connected:
            logger.debug("\(self.muse.getModel()) - \(self.muse.getName()): Connected. Versions: \(self.muse.getVersion()?.versionString ?? "NONE")")
        case .disconnected:
            remainingBatteryPercentage = nil
            wearingHeadband = false
            eyeBlink = false
            jawClench = false
            measurements = []
            // TODO reset isGood!

            self.muse.unregisterAllListeners()
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
                measurements.append(EEGSeries(from: packet))
            }
        case .battery:
            remainingBatteryPercentage = packet.getBatteryValue(.chargePercentageRemaining)
            logger.debug("Remaining battery percentage: \(packet.getBatteryValue(.chargePercentageRemaining))")
        case .isGood:
            // TODO actually mark the measurements?
            self.isGood = (
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
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        if packet.headbandOn != wearingHeadband {
            logger.debug("Wearing headband: \(packet.headbandOn)")
            wearingHeadband = packet.headbandOn
        }

        if packet.blink != eyeBlink {
            eyeBlink = packet.blink
            if packet.blink {
                logger.debug("Detected eye blink")
            }
        }

        if packet.jawClench != jawClench {
            jawClench = packet.jawClench
            if packet.jawClench {
                logger.debug("Detected jaw clench")
            }
        }
    }
}


extension IXNMuseVersion {
    var versionString: String {
        // TODO bootloader version? running state?
        "firmware: \(getFirmwareVersion()) (\(getFirmwareBuildNumber()) - \(getFirmwareType())), hardware: \(getHardwareVersion()), protocol: \(getProtocolVersion()), bsp: \(getBspVersion())"
    }
}
