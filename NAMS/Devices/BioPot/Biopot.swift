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
    @Environment(Bluetooth.self)
    private var bluetooth
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?

    @State private var viewState: ViewState = .idle

    var body: some View {
        ListRow("Nearby Devices") {
            Text(verbatim: "\(bluetooth.nearbyDevices(for: BiopotDevice.self).count)")
        }
        ListRow("Device") {
            if let biopot {
                Text(biopot.state.localizedStringResource)
            } else {
                Text("Scanning ...")
            }
        }
            .viewStateAlert(state: $viewState)
            .scanNearbyDevices(with: bluetooth, autoConnect: true)

        testingSupport

        if let biopot,
           let info = biopot.service.deviceInfo {
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
        } else {
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
                // TODO: allow testing support via a different SPI?
                // TODO: also this needs to inject a device instance?
                /*
                biopot.deviceInfo = DeviceInformation(
                    syncRatio: 0,
                    syncMode: false,
                    memoryWriteNumber: 0,
                    memoryEraseMode: false,
                    batteryLevel: 80,
                    temperatureValue: 23,
                    batteryCharging: false
                )*/
            }
        }
    }

    @MainActor @ViewBuilder private var actionButtons: some View {
        Section("Actions") { // section of testing actions
            AsyncButton("Read Device Configuration", state: $viewState) {
                try await biopot?.service.$deviceInfo.read()
            }
            AsyncButton("Read Data Control", state: $viewState) {
                try await biopot?.service.$dataControl.read()
            }
            AsyncButton("Read Data Acquisition", state: $viewState) {
                try await biopot?.service.$impedanceMeasurement.read()
            }
            AsyncButton("Read Sample Configuration", state: $viewState) {
                try await biopot?.service.$samplingConfiguration.read()
            }
        }
    }
}


extension BluetoothState: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unknown:
            "Unknown"
        case .poweredOn:
            "Bluetooth On"
        case .unsupported:
            "Bluetooth Unsupported"
        case .poweredOff:
            "Bluetooth Off"
        case .unauthorized:
            "Bluetooth Unauthorized"
        }
    }
}

extension PeripheralState: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .connected:
            "Connected"
        case .disconnected:
            "Disconnected"
        case .connecting:
            "Connecting"
        case .disconnecting:
            "Disconnecting"
        }
    }
}


#if DEBUG
#Preview {
    List {
        Biopot()
    }
        .previewWith {
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
        }
}
#endif
