//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog


#if MUSE
class MuseConnectionListener: DeviceConnectionListener, IXNMuseConnectionListener, IXNMuseDataListener {
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseConnectionListener")

    private let muse: IXNMuse
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

        // TODO control this
        // muse.register(self, type: .eeg)
        // Might want to read https://www.learningeeg.com/terminology-and-waveforms for a short intro into EEG frequency ranges
        muse.register(self, type: .thetaAbsolute) // 4-8 Hz
        muse.register(self, type: .alphaAbsolute) // 8-16 Hz
        muse.register(self, type: .betaAbsolute) // 16-32 Hz
        muse.register(self, type: .gammaAbsolute) // 32-64 Hz
        muse.register(self, type: .battery)
        muse.register(self, type: .isGood)

        muse.register(self, type: .hsiPrecision) // TODO capture and visualize

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

    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        device.state = ConnectionState(from: packet.currentConnectionState)
        logger.debug("\(self.muse.getName()) state is now \(self.device.state.description)")

        // TODO check if version is already present earlier? => Yes

        // TODO can we always query the serial number?

        switch device.state {
        case .connected:
            logger.debug("\(self.muse.getModel()) - \(self.muse.getName()): Connected. Versions: \(self.muse.getVersion()?.versionString ?? "NONE"); Configuration: \(self.muse.getConfiguration())")

            if let version = self.muse.getVersion() {
                logger.debug("\(self.muse.getModel()) - \(self.muse.getName()): Versions: \(version.versionString)")
            }

            if let configuration = self.muse.getConfiguration() {
                device.remainingBatteryPercentage = configuration.getBatteryPercentRemaining()

                logger.debug("\(self.muse.getModel()) - \(self.muse.getName()): Configuration: \(configuration.configurationString)")
            }
        case .disconnected:
            device.remainingBatteryPercentage = nil
            device.wearingHeadband = false
            device.eyeBlink = false
            device.jawClench = false
            device.measurements = [:]
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
        case .hsiPrecision:
            let fit = HeadbandFit(from: packet)
            if device.fit != fit {
                device.fit = fit
            }
        case .eeg:
            // TODO might also be NaN for dropped packets!
            /*
            logger.trace("""
                         \(self.muse.getName()) data: \
                         \(packet.getEegChannelValue(.EEG1)) \
                         \(packet.getEegChannelValue(.EEG2)) \
                         \(packet.getEegChannelValue(.EEG3)) \
                         \(packet.getEegChannelValue(.EEG4))
                         """)
             */
            // TODO maybe toggle collection only if the view is shown?
            // TODO reenable, review which threads does what work!
            // device.measurements[.all, default: []].append(EEGSeries(from: packet))
            break
        case .thetaAbsolute:
            device.measurements[.theta, default: []].append(EEGSeries(from: packet))
        case .alphaAbsolute:
            device.measurements[.alpha, default: []].append(EEGSeries(from: packet))
        case .betaAbsolute:
            device.measurements[.beta, default: []].append(EEGSeries(from: packet))
        case .gammaAbsolute:
            device.measurements[.gamma, default: []].append(EEGSeries(from: packet))
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
#endif
