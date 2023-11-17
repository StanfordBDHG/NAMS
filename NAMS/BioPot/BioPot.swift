//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziViews
import SwiftUI


struct BioPot: View {
    @Environment(BiopotDevice.self)
    private var biopot

    @State private var viewState: ViewState = .idle

    var body: some View {
        List {
            ListRow("Device") {
                Text(biopot.bluetoothState.localizedStringResource)
            }


            if let info = biopot.deviceInfo, biopot.bluetoothState == .connected {
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

                Section("Actions") { // section of testing actions
                    AsyncButton("Read Device Configuration", state: $viewState) {
                        try biopot.readBiopot(characteristic: BiopotDevice.Characteristic.biopotDeviceConfiguration)
                    }
                }
            } else {
                Section {
                    ProgressView()
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .frame(maxWidth: .infinity)
                }
            }
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle("BioPot 3")
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
            return "Scanning"
        case .poweredOff:
            return "Bluetooth Off"
        case .unauthorized:
            return "Bluetooth Unauthorized"
        }
    }
}


#if DEBUG
import Spezi

#Preview {
    class PreviewDelegate: SpeziAppDelegate {
        override var configuration: Configuration {
            Configuration {
                Bluetooth()
                BiopotDevice()
            }
        }
    }

    return BioPot()
        .spezi(PreviewDelegate())
}
#endif
