//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct NearbyDevices: View {
    @Environment(\.dismiss)
    private var dismiss

    @StateObject private var bluetoothManager = BluetoothManager()
    @ObservedObject private var museModel: MuseViewModel

    private var troubleshootingUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        // TODO ?language=en_US
        guard let docsUrl = URL(string: "https://choosemuse.my.site.com/s/article/Bluetooth-Troubleshooting") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    var body: some View {
        List {
            if case .poweredOn = bluetoothManager.bluetoothState {
                Text("Make sure your headband is turned on and nearby.")
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom, -4)
                    .padding([.top, .leading, .trailing])
            }

            Section {
                if case .poweredOn = bluetoothManager.bluetoothState {
                    if museModel.nearbyMuses.isEmpty {
                        // TODO if we disconnect this doesn't appear?
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        MuseDeviceList(museModel: museModel)
                    }
                }

                bluetoothHints
            } footer: {
                sectionFooter
            }
        }
            .navigationTitle("Nearby Devices")
            .onAppear {
                if case .poweredOn = bluetoothManager.bluetoothState {
                    museModel.startScanning()
                }
            }
            .onDisappear {
                museModel.stopScanning()
            }
            .onReceive(bluetoothManager.$bluetoothState) { newValue in
                if case .poweredOn = newValue {
                    museModel.startScanning()
                } else {
                    // this will still trigger an API MISUSE, both otherwise we end up in undefined state
                    museModel.stopScanning()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
    }

    @ViewBuilder var bluetoothHints: some View {
        Group {
            switch bluetoothManager.bluetoothState {
            case .poweredOn:
                EmptyView()
            case .poweredOff:
                VStack {
                    Text("Bluetooth Off")
                        .font(.title2)
                        .padding()

                    Text("""
                         Bluetooth is turned off. \
                         Please turn on Bluetooth in Control Center or Settings in order to use your Muse Headband.
                         """)
                        .multilineTextAlignment(.center)
                }
            case .unauthorized:
                VStack {
                    Text("Bluetooth Prohibited")
                        .font(.title2)
                        .padding()

                    Text("""
                         Bluetooth is required to make connections to your Muse Headband. \
                         Please allow Bluetooth connections in your Privacy settings.
                         """)
                        .multilineTextAlignment(.center)
                }
            case .resetting, .unknown:
                Text("We have troubles communicating with Bluetooth. Please try again.")
            case .unsupported:
                Text("Bluetooth is unsupported on this device!")
            @unknown default:
                EmptyView()
            }
        }
            .listRowBackground(Color.clear)
    }

    @ViewBuilder var sectionFooter: some View {
        HStack {
            Text("Do you have problems connecting?")
            Button(action: {
                UIApplication.shared.open(troubleshootingUrl)
            }) {
                Text("Troubleshooting")
                    .font(.footnote)
            }
        }
            .padding(.top)
    }


    init(museModel: MuseViewModel) {
        self.museModel = museModel
    }
}

struct MuseList_Previews: PreviewProvider {
    @StateObject static var model = MuseViewModel()
    static var previews: some View {
        NavigationStack {
            NearbyDevices(museModel: model)
        }
    }
}
