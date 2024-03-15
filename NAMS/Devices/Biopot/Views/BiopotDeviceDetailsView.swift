//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziViews
import SwiftUI


struct BiopotDeviceDetailsView: View {
    private let biopot: BiopotDevice
    private let disconnectClosure: () -> Void

    @Environment(\.dismiss)
    private var dismiss

    var hasAboutInformation: Bool {
        let deviceInformation = biopot.deviceInformation
        return deviceInformation.firmwareRevision != nil
            || deviceInformation.hardwareRevision != nil
            || deviceInformation.serialNumber != nil
    }

    var title: Text {
        if let name = biopot.name {
            Text(verbatim: name)
        } else {
            Text("Unknown Device")
        }
    }

    var isDisconnected: Bool {
        biopot.state == .disconnected || biopot.state == .disconnecting
    }

    var body: some View {
        List { // swiftlint:disable:this closure_body_length
            if let info = biopot.service.deviceInfo {
                Section {
                    ListRow("BATTERY") {
                        BatteryIcon(percentage: Int(info.batteryLevel), isCharging: info.batteryCharging)
                    }
                }
            }

            Section {
                NavigationLink {
                    BiopotElectrodeLocationsEditView(biopot: biopot)
                } label: {
                    ListRow("Electrode Locations") {
                        Text(biopot.configuration.electrodeSelection.localizedStringResource)
                    }
                }
            } footer: {
                Text("Configure the electrode locations for each channel of the Biopot.")
            }


            if hasAboutInformation {
                Section("About") {
                    if let firmware = biopot.deviceInformation.firmwareRevision {
                        ListRow("Firmware Version") {
                            Text(verbatim: firmware)
                        }
                    }
                    if let hardware = biopot.deviceInformation.hardwareRevision {
                        ListRow("Hardware Version") {
                            Text(verbatim: hardware)
                        }
                    }
                    if let serialNumber = biopot.deviceInformation.serialNumber {
                        ListRow("Serial Number") {
                            Text(verbatim: serialNumber)
                        }
                    }
                }
            }

            disconnectButton
        }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .onChange(of: biopot.state) {
                if isDisconnected {
                    dismiss()
                }
            }
    }

    @ViewBuilder var disconnectButton: some View {
        Section {
            Button(action: {
                disconnectClosure()
            }) {
                Text("Disconnect")
                    .frame(maxWidth: .infinity)
            }
            .disabled(isDisconnected)
        } footer: {
            if isDisconnected {
                Text("This device is no longer connected.")
            }
        }
    }


    init(device: BiopotDevice, disconnect: @escaping () -> Void) {
        self.biopot = device
        self.disconnectClosure = disconnect
    }
}


#if DEBUG
#Preview {
    let biopot = BiopotDevice.createMock(state: .connected)

    return NavigationStack {
        BiopotDeviceDetailsView(device: biopot) {
            Task {
                await biopot.disconnect()
            }
        }
    }
}

#Preview {
    let biopot = BiopotDevice.createMock()
    return NavigationStack {
        BiopotDeviceDetailsView(device: biopot) {
            Task {
                await biopot.disconnect()
            }
        }
    }
}
#endif
