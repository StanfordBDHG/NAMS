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
    @Environment(\.locale)
    private var locale

    @StateObject private var bluetoothManager = BluetoothManager()
    @ObservedObject private var eegModel: EEGViewModel

    private var bluetoothPoweredOn: Bool {
        if case .poweredOn = bluetoothManager.bluetoothState {
            return true
        }
        #if targetEnvironment(simulator)
        return true
        #else
        return ProcessInfo.processInfo.isPreviewSimulator
        #endif
    }

    var body: some View {
        NavigationStack { // swiftlint:disable:this closure_body_length
            List {
                if bluetoothPoweredOn {
                    Text("TURN_ON_HEADBAND_HINT")
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding([.top, .leading, .trailing])
                }

                Section {
                    if bluetoothPoweredOn {
                        if eegModel.nearbyDevices.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            EEGDeviceList(eegModel: eegModel)
                        }
                    }

                    bluetoothHints
                } footer: {
                    sectionFooter
                }
            }
            .navigationTitle("NEARBY_DEVICES")
            .onAppear {
                if bluetoothPoweredOn {
                    eegModel.startScanning()
                }
            }
            .onDisappear {
                eegModel.stopScanning(refreshNearby: bluetoothManager.bluetoothState == .poweredOn)
            }
            .onReceive(bluetoothManager.$bluetoothState) { newValue in
                if case .poweredOn = newValue {
                    eegModel.startScanning()
                } else {
                    // this will still trigger an API MISUSE, both otherwise we end up in undefined state
                    eegModel.stopScanning(refreshNearby: bluetoothManager.bluetoothState == .poweredOn)
                }
            }
            .toolbar {
                Button("CLOSE") {
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
                    Text("BLUETOOTH_OFF")
                        .font(.title2)
                        .padding()

                    Text("BLUETOOTH_OFF_HINT")
                        .multilineTextAlignment(.center)
                }
            case .unauthorized:
                VStack {
                    Text("BLUETOOTH_PROHIBITED")
                        .font(.title2)
                        .padding()

                    Text("BLUETOOTH_PROHIBITED_HINT")
                        .multilineTextAlignment(.center)
                }
            case .resetting, .unknown:
                Text("BLUETOOTH_UNKNOWN")
            case .unsupported:
                if bluetoothPoweredOn {
                    EmptyView() // handle preview case
                } else {
                    Text("BLUETOOTH_UNSUPPORTED")
                }
            @unknown default:
                EmptyView()
            }
        }
            .listRowBackground(Color.clear)
    }

    @ViewBuilder var sectionFooter: some View {
        HStack {
            let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
            Text("PROBLEMS_CONNECTING_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Bluetooth-Troubleshooting?language=\(locale.identifier))")
        }
            .padding(.top)
    }


    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }
}


struct MuseList_Previews: PreviewProvider {
    @StateObject static var model = EEGViewModel(deviceManager: MockDeviceManager())

    static var previews: some View {
        NavigationStack {
            NearbyDevices(eegModel: model)
        }
    }
}
