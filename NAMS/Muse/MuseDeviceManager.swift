//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog


#if MUSE
class MuseDeviceManager: DeviceManager, IXNLogListener {
    private class MuseListener: IXNMuseListener { // avoids cyclic references caused by setMuseListener
        private unowned let deviceManager: MuseDeviceManager


        init(deviceManager: MuseDeviceManager) {
            self.deviceManager = deviceManager
        }


        func museListChanged() {
            deviceManager.nearbyMuses = self.deviceManager.museManager.getMuses()
        }
    }

    private let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDeviceManager")

    private let museManager: IXNMuseManager
    private var museListener: MuseListener?

    @Published var nearbyMuses: [EEGDevice] = []

    var devicePublisher: Published<[EEGDevice]>.Publisher {
        $nearbyMuses
    }

    init() {
        self.museManager = IXNMuseManagerIos()
        
        self.museListener = nil
        self.museListener = MuseListener(deviceManager: self)

        self.museManager.setMuseListener(museListener)
    }

    func startScanning() {
        self.museManager.startListening()
    }

    func stopScanning() {
        self.museManager.stopListening()
    }

    func retrieveDeviceList() -> [EEGDevice] {
        self.museManager.getMuses()
    }

    func receiveLog(_ log: IXNLogPacket) {
        // we currently don't register the log manager
        logger.debug("\(log.tag): \(log.timestamp) raw:\(log.raw) \(log.message)")
    }
}
#endif
