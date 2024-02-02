//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import Spezi
import SpeziBluetooth
import SwiftUI


struct NearbyDevicesView: View {
    @Environment(Bluetooth.self)
    private var bluetooth
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Environment(BiopotDevice.self)
    private var biopotDevice: BiopotDevice?
#if MUSE
    @Environment(MuseDeviceManager.self)
    private var museDeviceManager
#endif
    @Environment(MockDeviceManager.self)
    private var mockDeviceManager: MockDeviceManager? // TODO: flag to disable mock devices!

    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(StorageKeys.autoConnect)
    private var autoConnect = false
    @AppStorage(StorageKeys.autoConnectBackground)
    private var autoConnectBackground = false // TODO: declared twice?


    private var consideredPoweredOn: Bool {
        mockDeviceManager != nil || bluetooth.state == .poweredOn
    }


    private var isScanning: Bool {
        mockDeviceManager != nil || bluetooth.isScanning
    }

    var body: some View {
        // TODO: remove closure length!
        // swiftlint:disable:next closure_body_length
        NavigationStack {
            List {
                Section {
                    Toggle("Auto Connect", isOn: $autoConnect)
                    if autoConnect {
                        Toggle("Continuous Background Search", isOn: $autoConnectBackground) // TODO: make it a selection navigation destination?
                    }
                } footer: {
                    Text("Automatically connect to nearby SensoMedical BIOPOT3 devices.")
                }

                if consideredPoweredOn {
                    // TODO: sort all devices by initial discovery (descending?, latest at the top!)
                    Section {
                        #if MUSE
                        MuseDeviceList()
                        #endif

                        let biopots = bluetooth.nearbyDevices(for: BiopotDevice.self)
                        ForEach(biopots) { biopot in
                            BiopotDeviceRow(device: biopot)
                        }

                        if let mockDeviceManager {
                            ForEach(mockDeviceManager.nearbyDevices) { device in
                                MockDeviceRow(device: device)
                            }
                        }
                    } header: {
                        LoadingSectionHeaderView("Devices", loading: isScanning)
                    } footer: {
                        MuseTroublesConnectingHint() // TODO: that doesn't apply to all devices?
                    }
                } else {
                    Section {
                        BluetoothStateHint(bluetooth.state)
                    }
                }
            }
                .navigationTitle("NEARBY_DEVICES")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
        }
            // TODO: auto-connect also conflicts with Muse devices? (enough to disable autoConnect if we have something connected?)
            .scanNearbyDevices(with: bluetooth, autoConnect: autoConnect && !deviceCoordinator.isConnected)
            .scanNearbyDevices(enabled: mockDeviceManager != nil, with: mockDeviceManager ?? MockDeviceManager())
#if MUSE
            .scanNearbyDevices(enabled: bluetooth.state == .poweredOn, with: museDeviceManager)
            .onChange(of: bluetooth.state) {
                if case .poweredOn = bluetooth.state {
                    museDeviceManager.startScanning()
                } else {
                    // this will still trigger an API MISUSE, but otherwise we end up in undefined state
                    // TODO: museDeviceManager.stopScanning()
                }
            }
#endif
    }


    init() {}
}


#if DEBUG
#Preview {
    NearbyDevicesView()
        .previewWith {
            DeviceCoordinator()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
        }
#if MUSE
        .environment(MuseDeviceManager()) // TODO: make this a module?
#endif
        .environment(MockDeviceManager())
}

#Preview {
    NearbyDevicesView()
        .previewWith {
            DeviceCoordinator()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
        }
#if MUSE
        .environment(MuseDeviceManager()) // TODO: make this a module?
#endif
        .environment(MockDeviceManager())
}
#endif
