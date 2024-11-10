//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
import OSLog
@_spi(APISupport)
import SpeziBluetooth
import SwiftUI


#if MUSE
@Observable
@MainActor
final class MuseDeviceManager {
    private static let discoveryTimeout: Int64 = 10
    private nonisolated let logger = Logger(subsystem: "edu.stanford.NAMS", category: "MuseDeviceManager")

    private nonisolated let museManager: IXNMuseManager
    @ObservationIgnored private var museListener: MuseListener?

    /// The list of nearby muse devices.
    private(set) var nearbyMuses: [MuseDevice] = []
    /// When the app gets to sleep Muse doesn't continue to count down their stale timer and doesn't remove devices.
    /// Therefore, we hide them base on the last seen time. However, we don't get notified when the device is suddenly discoverable again.
    /// So we will actively poll hidden devices if we have some.
    private var hiddenMuseDevices: Set<IXNMuse> = []
    private var hiddenDevicesTimer: Timer? {
        willSet {
            hiddenDevicesTimer?.invalidate()
        }
    }

    private var lastKnownBluetoothState: BluetoothState = .unknown

    var connectedMuse: MuseDevice? {
        nearbyMuses.first { muse in
            muse.state == .connected
        }
    }

    init() {
        self.museManager = IXNMuseManagerIos()
        self.museListener = MuseListener(deviceManager: self)

        if let apiVersion = IXNLibmuseVersion.instance() {
            logger.debug("Initialized Muse Manager with version \(apiVersion.getString())")
        }

        self.museManager.removeFromList(after: Self.discoveryTimeout) // stale timeout if there isn't an updated advertisement
    }

    func startScanning() {
        logger.debug("Start scanning for nearby Muse devices...")
        if lastKnownBluetoothState == .poweredOff {
            self.museManager.stopListening() // make sure it is balanced
        }

        self.lastKnownBluetoothState = .poweredOn
        self.museManager.startListening()
        handleUpdatedDeviceList(museManager.getMuses())
    }

    func stopScanning(state: BluetoothState) {
        logger.debug("Stopped scanning for nearby Muse devices!")
        self.lastKnownBluetoothState = state
        if state == .poweredOn {
            self.museManager.stopListening()
        }

        if state != .poweredOn {
            // MuseManager stops its stale timer once we stop listening.
            // If we are stopping because Bluetooth turned off, we just assume all devices to be hidden.
            for device in nearbyMuses {
                logger.debug("\(device.label) is considered hidden as bluetooth was disabled.")
                hiddenMuseDevices.insert(device.underlyingDevice)
            }
            nearbyMuses.removeAll()

            checkHiddenTimerScheduled()
        }
    }

    func stopScanning() {
        // we are called from the modifier, so state must be powered on
        stopScanning(state: .poweredOn)
    }

    private func isHiddenDevice(_ muse: IXNMuse) -> Bool {
        if lastKnownBluetoothState == .poweredOff {
            return true // we consider all devices hidden when bluetooth is off
        }

        let lastTime = muse.getLastDiscoveredTime()
        guard !lastTime.isNaN && muse.getConnectionState() == .disconnected else {
            return false // just accept those that don't expose a time
        }

        // that's how muse calculates the discovered time
        let now = CACurrentMediaTime() * 1000.0 * 1000.0

        let delta = max(0, now - lastTime)

        return delta > (Double(Self.discoveryTimeout) * 1000.0 * 1000.0)
    }


    private func handleUpdatedDeviceList(_ museList: [IXNMuse]) {
        MainActor.assertIsolated("Muse List was not updated on Main Actor!")
        var nearbyMuses = Set(museList)

        // check if a hidden muse is gone now
        for muse in hiddenMuseDevices where !nearbyMuses.contains(muse) {
            hiddenMuseDevices.remove(muse)
        }

        // check if muse is hidden or a hidden one is not hidden anymore?
        for muse in nearbyMuses {
            if isHiddenDevice(muse) {
                hiddenMuseDevices.insert(muse)

                nearbyMuses.remove(muse)
                logger.debug("\(muse.getModel()) - \(muse.getName()) is stale and we are hiding it.")
            } else {
                hiddenMuseDevices.remove(muse)
            }
        }

        // remove all muses that went away
        for (index, removedMuse) in zip(self.nearbyMuses.indices, self.nearbyMuses).reversed() {
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

        checkHiddenTimerScheduled()
    }

    private func checkHiddenMuseDevices() {
        var hiddenDeviceUpdated = false

        for device in hiddenMuseDevices where !isHiddenDevice(device) {
            // device updated again
            logger.debug("\(device.getModel()) - \(device.getName()) is not hidden anymore!")
            hiddenDeviceUpdated = true
            break
        }

        if hiddenDeviceUpdated {
            hiddenDevicesTimer = nil
            handleUpdatedDeviceList(museManager.getMuses())
        }
    }

    private func checkHiddenTimerScheduled() {
        if hiddenMuseDevices.isEmpty {
            hiddenDevicesTimer = nil
        } else if hiddenDevicesTimer == nil {
            let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else {
                    return
                }
                MainActor.assumeIsolated {
                    self.checkHiddenMuseDevices()
                }
            }
            hiddenDevicesTimer = timer
            RunLoop.main.add(timer, forMode: .common)
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

    @MainActor
    func scanNearbyDevices(_ state: EmptyScanningState) async {
        self.startScanning()
    }

    func updateScanningState(_ state: EmptyScanningState) async {}
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

            let museList = deviceManager.museManager.getMuses()

            Task { @MainActor in
                deviceManager.handleUpdatedDeviceList(museList)
            }
        }

        deinit {
            deviceManager?.museManager.setMuseListener(nil)
        }
    }
}
#endif
