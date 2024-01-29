//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
import OSLog
import SpeziBluetooth


#if MUSE
@Observable
class MuseDeviceManager {
    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDeviceManager")

    private let museManager: IXNMuseManager
    @ObservationIgnored private var museListener: MuseListener?

    /// The list of nearby muse devices.
    private(set) var nearbyMuses: [MuseDevice] = []
    // TODO: isScanning property

    init() {
        self.museManager = IXNMuseManagerIos()
        self.museListener = MuseListener(deviceManager: self)

        if let apiVersion = IXNLibmuseVersion.instance() {
            logger.debug("Initialized Muse Manager with API version \(apiVersion.getString())")
        }

        self.museManager.removeFromList(after: 6) // stale timeout if there isn't an updated advertisement
    }

    func startScanning() {
        logger.debug("Start scanning for nearby Muse devices...")
        self.museManager.startListening()
    }

    func stopScanning() {
        logger.debug("Stopped scanning for nearby Muse devices!")
        // TODO: check if we are still scanning?
        self.museManager.stopListening()
    }


    private func handleUpdatedDeviceList() {
        let nearbyMuses = museManager.getMuses()

        // remove all muses that went away
        for (index, removedMuse) in self.nearbyMuses.enumerated() {
            guard !nearbyMuses.contains(removedMuse.underlyingDevice) else {
                continue
            }
            self.nearbyMuses.remove(at: index)
        }

        for addedMuse in nearbyMuses {
            guard !self.nearbyMuses.contains(where: { $0.underlyingDevice == addedMuse }) else {
                continue
            }
            self.nearbyMuses.append(MuseDevice(addedMuse))
        }
    }

    deinit {
        self.museListener = nil
    }
}


extension MuseDeviceManager: BluetoothScanner {
    var hasConnectedDevices: Bool {
        nearbyMuses.contains { device in
            device.state != .disconnected
        }
    }

    func scanNearbyDevices(autoConnect: Bool) async {
        precondition(!autoConnect, "AutoConnect is unsupported on \(Self.self)")
        self.startScanning()
    }
}


extension MuseDeviceManager {
    private class MuseListener: IXNMuseListener { // avoids cyclic references caused by setMuseListener
        private weak var deviceManager: MuseDeviceManager?


        init(deviceManager: MuseDeviceManager) {
            self.deviceManager = deviceManager
            deviceManager.museManager.setMuseListener(self)
        }


        func museListChanged() {
            guard let deviceManager else {
                return
            }
            deviceManager.handleUpdatedDeviceList()
        }

        deinit {
            deviceManager?.museManager.setMuseListener(nil)
        }
    }
}
#endif
