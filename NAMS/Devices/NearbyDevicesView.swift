//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

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

    // TODO: implement!
    @AppStorage(StorageKeys.autoConnect)
    private var autoConnect = true
    @AppStorage(StorageKeys.autoConnectBackground)
    private var autoConnectBackground = false


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
            List { // swiftlint:disable:this closure_body_length
                Section {
                    Toggle("Auto Connect", isOn: $autoConnect)
                    if autoConnect {
                        Toggle("Auto Connect Background", isOn: $autoConnectBackground) // TODO: make it a selection navigation destination?
                    }
                }

                if consideredPoweredOn {
                    Section { // TODO: think about this placement?
                        Text("TURN_ON_HEADBAND_HINT")
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowBackground(Color.clear)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

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
                        LoadingSectionHeader("Devices", loading: isScanning)
                    } footer: {
                        MuseTroublesConnectingHint()
                    }
                } else {
                    Section {
                        BluetoothStateHints(state: bluetooth.state)
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
            // TODO: this probably conflicts with a global .autoConnect modifier!
            // TODO: auto-connect also conflicts with Muse devices? (enough to disable autoConnect if we have something connected?)
            .scanNearbyDevices(with: bluetooth, autoConnect: false) // TODO: allow to dynamically disable autoConnect!
            // TODO: how to handle optional modifiers?
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
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
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
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
        }
#if MUSE
        .environment(MuseDeviceManager()) // TODO: make this a module?
#endif
        .environment(MockDeviceManager())
}
#endif
