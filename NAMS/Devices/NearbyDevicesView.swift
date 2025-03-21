//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth
import SpeziDevicesUI
import SpeziViews
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

    @State private var navigationPath = NavigationPath()

#if targetEnvironment(simulator)
    @State private var mockBiopot = BiopotDevice.createMock()
#endif


    private var consideredPoweredOn: Bool {
#if targetEnvironment(simulator)
        true // mock biopot is there in every case
#else
        mockDeviceManager != nil || bluetooth.state == .poweredOn
#endif
    }


    private var isScanning: Bool {
        mockDeviceManager != nil || bluetooth.isScanning
    }

    var body: some View {
        @Bindable var deviceCoordinator = deviceCoordinator

        NavigationStack(path: $navigationPath) {
            List {
                autoConnectLink

                if consideredPoweredOn {
                    nearbyDevicesSection
                } else {
                    Section {
                        BluetoothUnavailableView(bluetooth.state)
                    }
                }
            }
                .navigationTitle("NEARBY_DEVICES")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ConnectedDevice.self) { device in
                    ConnectedDeviceDestination(device: device)
                }
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
        }
            .scanNearbyDevices(with: bluetooth, autoConnect: deviceCoordinator.shouldAutoConnectBiopot)
            .scanNearbyDevices(enabled: mockDeviceManager != nil, with: mockDeviceManager ?? MockDeviceManager())
#if MUSE
            .scanNearbyDevices(with: museDeviceManager)
            .onChange(of: bluetooth.state) {
                if case .poweredOn = bluetooth.state {
                    museDeviceManager.startScanning()
                } else {
                    museDeviceManager.stopScanning(state: bluetooth.state)
                }
            }
#endif
    }

    @ViewBuilder private var autoConnectLink: some View {
        Section {
            NavigationLink {
                AutoConnectConfigurationView()
            } label: {
                ListRow("Auto Connect") {
                    Text(deviceCoordinator.autoConnectOption.localizedStringResource)
                }
            }
        } footer: {
            Text("Automatically connect to nearby SensoMedical BIOPOT3 devices.")
        }
    }

    @ViewBuilder @MainActor private var nearbyDevicesSection: some View {
        Section {
#if MUSE
            MuseDeviceList(path: $navigationPath)
#endif

#if targetEnvironment(simulator)
            BiopotDeviceRow(device: mockBiopot, path: $navigationPath)
#endif

            let biopots = bluetooth.nearbyDevices(for: BiopotDevice.self)
            ForEach(biopots) { biopot in
                BiopotDeviceRow(device: biopot, path: $navigationPath)
            }

            if let mockDeviceManager {
                ForEach(mockDeviceManager.nearbyDevices) { device in
                    MockDeviceRow(device: device, path: $navigationPath)
                }
            }
        } header: {
            LoadingSectionHeader("Devices", loading: isScanning)
        } footer: {
            MuseTroublesConnectingHint()
        }
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
