//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import CoreBluetooth
import Foundation
import OSLog

class ConnectedMuse: ObservableObject, IXNMuseConnectionListener, IXNMuseDataListener {
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDevice")

    let muse: IXNMuse

    @Published var state: IXNConnectionState = .unknown // TODO we can also query that state directly!

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

        // TODO what other packets to register?
        muse.register(self, type: .artifacts)
        muse.register(self, type: .alphaAbsolute)

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
            // TODO optimize data access, there seems to be proper APIs
            logger.debug("""
                         \(self.muse.getName()) data: \
                         \(packet.values()[IXNEeg.EEG1.rawValue].doubleValue) \
                         \(packet.values()[IXNEeg.EEG2.rawValue].doubleValue) \
                         \(packet.values()[IXNEeg.EEG3.rawValue].doubleValue) \
                         \(packet.values()[IXNEeg.EEG4.rawValue].doubleValue)
                         """)
        }
    }

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

class MuseViewModel: NSObject, CBCentralManagerDelegate, IXNMuseListener, IXNLogListener, ObservableObject {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "Muse")

    private let museManager: IXNMuseManager
    private let bluetoothManager: CBCentralManager

    @Published var bluetoothEnabled = false
    @Published var nearbyMuses: [IXNMuse] = []

    var activeMuse: ConnectedMuse? // TODO propagate updates
    var activeMuseCancelable: AnyCancellable?
    // TODO publish muse devices!

    override init() {
        self.museManager = IXNMuseManagerIos()
        self.bluetoothManager = CBCentralManager()

        super.init()

        // TODO are these references as cyclic
        self.museManager.setMuseListener(self)
        self.bluetoothManager.delegate = self // TODO nsObject dependency!
    }

    func museListChanged() {
        self.nearbyMuses = self.museManager.getMuses()
        // TODO query: self.museManager.getMuses()
    }

    func receiveLog(_ log: IXNLogPacket) {
        // TODO do we want to display the log?
        logger.debug("\(log.tag): \(log.timestamp) raw:\(log.raw) \(log.message)")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothEnabled = (central.state == .poweredOn)
    }

    func startScanning() {
        // TODO as a task?
        self.museManager.startListening()
        museListChanged()
    }

    func reloadScanning() {
        stopScanning()
        startScanning() // TODO this will reset the active device as well
    }

    func stopScanning() {
        self.museManager.stopListening()
        museListChanged() // TODO use that? or empty?
    }

    func tapMuse(atIndex index: Int) {
        guard index < nearbyMuses.count else {
            return
        }

        let muse = nearbyMuses[index]
        if let activeMuse {
            if activeMuse.muse == muse { // TODO is this check fine
                activeMuse.muse.disconnect()
                return // already connected
            }

            // TODO disconnect active muse
            activeMuse.muse.disconnect()
            activeMuseCancelable?.cancel()
            activeMuseCancelable = nil
            self.activeMuse = nil
        }

        let activeMuse = ConnectedMuse(muse: muse)
        activeMuseCancelable = activeMuse.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }

        activeMuse.connect() // TODO handle connection errors?
        self.activeMuse = activeMuse
    }
}


extension IXNConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnected:
            return "disconnected"
        case .needsUpdate:
            return "needsUpdate"
        @unknown default:
            return "unknown"
        }
    }
}


extension IXNMuseModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mu01:
            return "Muse (2014)"
        case .mu02:
            return "Muse (2016)"
        case .mu03:
            return "Muse 2"
        case .mu04:
            return "Muse S" // 2019
        case .mu05:
            return "Muse s (Gen 2)"
        }
    }
}
