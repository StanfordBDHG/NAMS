//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct NearbyDevices: View {
    private let eegModel: EEGViewModel

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.locale)
    private var locale

    @State private var bluetoothManager = BluetoothManager()

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
                    onForeground()
                }
                .onDisappear {
                    onBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
                    onForeground() // onAppear is coupled with view rendering only and won't get fired when putting app into the foreground
                }
                .onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)) { _ in
                    onBackground() // onDisappear is coupled with view rendering only and won't get fired when putting app into the background
                }
                .onChange(of: bluetoothManager.bluetoothState) {
                    if case .poweredOn = bluetoothManager.bluetoothState {
                        eegModel.startScanning()
                    } else {
                        // this will still trigger an API MISUSE, both otherwise we end up in undefined state
                        eegModel.stopScanning(refreshNearby: bluetoothManager.bluetoothState == .poweredOn)
                    }
                }
                .toolbar {
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
                if !bluetoothPoweredOn { // preview case
                    Text("BLUETOOTH_UNKNOWN")
                }
            case .unsupported:
                if !bluetoothPoweredOn {
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


    @MainActor
    func onForeground() {
        if bluetoothPoweredOn {
            eegModel.startScanning()
        }
    }

    @MainActor
    func onBackground() {
        eegModel.stopScanning(refreshNearby: bluetoothManager.bluetoothState == .poweredOn)
    }
}


#if DEBUG
#Preview {
    let model = EEGViewModel(deviceManager: MockDeviceManager())
    return NavigationStack {
        NearbyDevices(eegModel: model)
    }
}
#endif
