//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth
import SpeziViews
import SwiftUI


struct Biopot: View {
    @Environment(BiopotDevice.self)
    private var biopot

    @State private var viewState: ViewState = .idle

    var body: some View {
        ListRow("Device") {
            Text(biopot.bluetoothState.localizedStringResource)
        }
            .viewStateAlert(state: $viewState)
            .onChange(of: biopot.bluetoothState) {
                if biopot.bluetoothState != .connected {
                    biopot.deviceInfo = nil
                }
            }

        testingSupport


        if let info = biopot.deviceInfo {
            Section("Status") {
                ListRow("BATTERY") {
                    BatteryIcon(percentage: Int(info.batteryLevel))
                }
                ListRow("Charging") {
                    if info.batteryCharging {
                        Text("Yes")
                    } else {
                        Text("No")
                    }
                }
                ListRow("Temperature") {
                    Text("\(info.temperatureValue) °C")
                }
            }

            actionButtons
        } else if biopot.bluetoothState == .scanning {
            Section {
                ProgressView()
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @MainActor @ViewBuilder private var testingSupport: some View {
        if FeatureFlags.testBiopot {
            Button("Receive Device Info") {
                biopot.deviceInfo = DeviceInformation(
                    syncRatio: 0,
                    syncMode: false,
                    memoryWriteNumber: 0,
                    memoryEraseMode: false,
                    batteryLevel: 80,
                    temperatureValue: 23,
                    batteryCharging: false
                )
            }
        }
    }

    @MainActor @ViewBuilder private var actionButtons: some View {
        Section("Actions") { // section of testing actions
            AsyncButton("Read Device Configuration", state: $viewState) {
                try biopot.readBiopot(characteristic: BiopotDevice.Characteristic.biopotDeviceConfiguration)
            }
            AsyncButton("Read Data Control", state: $viewState) {
                try biopot.readBiopot(characteristic: BiopotDevice.Characteristic.biopotDataControl)
            }
            AsyncButton("Read Data Acquisition", state: $viewState) {
                try biopot.readBiopot(characteristic: BiopotDevice.Characteristic.biopotImpedanceMeasurement)
            }
            AsyncButton("Read Sample Configuration", state: $viewState) {
                try biopot.readBiopot(characteristic: BiopotDevice.Characteristic.biopotSamplingConfiguration)
            }
        }
    }
}


extension BluetoothState: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .scanning:
            return "Scanning ..."
        case .poweredOff:
            return "Bluetooth Off"
        case .unauthorized:
            return "Bluetooth Unauthorized"
        }
    }
}


#if DEBUG
#Preview {
    List {
        Biopot()
    }
        .biopotPreviewSetup()
}
#endif
