//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
import SpeziBluetooth


@Observable
class MockDeviceManager {
    static let defaultNearbyDevices: [MockDevice] = [
        MockDevice(name: "Mock Device 1"),
        MockDevice(name: "Mock Device 2")
    ]

    private let storedDevicesList: [MockDevice]

    @ObservationIgnored private var previouslyDiscovered = false
    var nearbyDevices: [MockDevice] = []
    @ObservationIgnored private var task: Task<Void, Never>? {
        willSet {
            task?.cancel()
        }
    }


    init(nearbyDevices: [MockDevice] = MockDeviceManager.defaultNearbyDevices, immediate: Bool = false) {
        self.storedDevicesList = nearbyDevices
        if immediate {
            self.nearbyDevices = nearbyDevices
        }
    }


    func startScanning() {
        if !previouslyDiscovered {
            task = Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else {
                    return
                }
                nearbyDevices = storedDevicesList
                previouslyDiscovered = true
            }
        } else {
            nearbyDevices = storedDevicesList
        }
    }

    func stopScanning() {
        task = Task { @MainActor in
            nearbyDevices.removeAll { device in
                device.state == .disconnected
            }
        }
    }
}


// TODO: extension MockDeviceManager: BluetoothScanner {
extension MockDeviceManager {
    var hasConnectedDevices: Bool {
        nearbyDevices.contains { device in
            device.state != .disconnected
        }
    }

    func scanNearbyDevices(autoConnect: Bool) async {
        precondition(!autoConnect, "AutoConnect is unsupported on \(Self.self)")
        self.startScanning()
    }

    func setAutoConnect(_ autoConnect: Bool) async {
        precondition(!autoConnect, "AutoConnect is unsupported on \(Self.self)")
    }
}
