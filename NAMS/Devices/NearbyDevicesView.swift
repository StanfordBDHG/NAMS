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
    private var mockDeviceManager: MockDeviceManager?

    @Environment(\.dismiss)
    private var dismiss


    private var consideredPoweredOn: Bool {
        mockDeviceManager != nil || bluetooth.state == .poweredOn
    }


    private var isScanning: Bool {
        mockDeviceManager != nil || bluetooth.isScanning
    }

    var body: some View {
        @Bindable var deviceCoordinator = deviceCoordinator
        // TODO: remove closure length!
        // swiftlint:disable:next closure_body_length
        NavigationStack {
            List {
                Section {
                    // TODO: AutoConnect feature: On, In Background, Off
                    Toggle("Auto Connect", isOn: $deviceCoordinator.autoConnect)
                    if deviceCoordinator.autoConnect {
                        // TODO: make it a selection navigation destination?
                        Toggle("Continuous Background Search", isOn: $deviceCoordinator.autoConnectBackground)
                    }
                } footer: {
                    Text("Automatically connect to nearby SensoMedical BIOPOT3 devices.")
                }

                if consideredPoweredOn {
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
                        MuseTroublesConnectingHint()
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
            .scanNearbyDevices(with: bluetooth, autoConnect: deviceCoordinator.shouldAutoConnectBiopot)
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
        .environment(MuseDeviceManager())
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
        .environment(MuseDeviceManager())
#endif
        .environment(MockDeviceManager())
}
#endif
