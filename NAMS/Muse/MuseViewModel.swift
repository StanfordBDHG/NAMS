//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation
import OSLog


class MuseViewModel: IXNMuseListener, IXNLogListener, ObservableObject {
    let logger = Logger(subsystem: "edu.stanford.NAMS", category: "Muse")
    // TODO Log API version somewhere?

    private let museManager: IXNMuseManager

    @Published var nearbyMuses: [IXNMuse] = []

    @Published var activeMuse: ConnectedMuse? // TODO propagate updates
    var activeMuseCancelable: AnyCancellable?
    // TODO publish muse devices!

    init() {
        self.museManager = IXNMuseManagerIos()

        // TODO are these references cyclic?
        self.museManager.setMuseListener(self)
    }

    @MainActor
    func museListChanged() {
        self.nearbyMuses = self.museManager.getMuses()
    }

    func receiveLog(_ log: IXNLogPacket) {
        // TODO do we want to display the log?
        logger.debug("\(log.tag): \(log.timestamp) raw:\(log.raw) \(log.message)")
    }

    @MainActor
    func startScanning() {
        // TODO as a task?
        self.museManager.startListening()
        museListChanged()
    }

    @MainActor
    func stopScanning() {
        self.museManager.stopListening()
        museListChanged()
    }

    @MainActor
    func tapMuse(_ muse: IXNMuse) {
        if let activeMuse {
            // either we tapped on the same Muse or on another one, in any case disconnect the currently active Muse
            activeMuse.muse.disconnect()
            activeMuseCancelable?.cancel()
            activeMuseCancelable = nil
            self.activeMuse = nil


            if activeMuse.muse == muse {
                // if the tapped one was the active one return
                return
            }
        }

        let activeMuse = ConnectedMuse(muse: muse)
        activeMuseCancelable = activeMuse.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            if activeMuse.state == .disconnected { // TODO we might attempt to reconnect!
                self?.activeMuseCancelable?.cancel()
                self?.activeMuseCancelable = nil
                self?.activeMuse = nil
            }
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
        case .needsLicense: // TODO what impact does it have?
            return "needsLicense"
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
        @unknown default:
            return "Unknown Muse"
        }
    }
}
