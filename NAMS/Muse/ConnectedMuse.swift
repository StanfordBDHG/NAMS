//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog


class ConnectedMuse: ObservableObject, IXNMuseConnectionListener, IXNMuseDataListener {
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDevice")

    let muse: IXNMuse

    @Published var state: IXNConnectionState = .unknown

    // artifacts muse supports
    @Published var wearingHeadband = false
    @Published var eyeBlink = false
    @Published var jawClench = false

    init(muse: IXNMuse) {
        self.muse = muse
    }

    func connect() {
        // TODO is this a cyclic dependency now?
        muse.register(self)

        // TODO support IXNMuseDataPacketTypeHsiPrecision (for how good it fits!)
        // TODO expose IXNMuseDataPacketTypeIsGood

        // TODO display IXNMuseDataPacketTypeBattery

        // TODO what other packets to register?
        // TODO threading?
        muse.register(self, type: .artifacts)
        muse.register(self, type: .alphaAbsolute) // TODO frequencies guide https://www.learningeeg.com/terminology-and-waveforms

        muse.runAsynchronously()
    }

    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        // TODO verify same muse?
        // TODO handle firmware update
        self.state = packet.currentConnectionState
        logger.debug("\(self.muse.getName()) state is now \(self.state.description)")
        // TODO handle previous connection state?
    }

    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        guard let packet else {
            return
        }
        // TODO parse data packet
        if packet.packetType() == .alphaAbsolute || packet.packetType() == .eeg {
            // TODO might also be NaN for dropped packets!
            logger.debug("""
                         \(self.muse.getName()) data: \
                         \(packet.getEegChannelValue(.EEG1)) \
                         \(packet.getEegChannelValue(.EEG2)) \
                         \(packet.getEegChannelValue(.EEG3)) \
                         \(packet.getEegChannelValue(.EEG4))
                         """)
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
