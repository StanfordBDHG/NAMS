//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EEGDeviceDetails: View {
    @Environment(\.dismiss)
    private var dismiss

    private let device: ConnectedDevice

    var body: some View {
        List {
            if device.state == .interventionRequired {
                // TODO implement
                EmptyView()
            }


            battery

            headbandFit


            // TODO about information
            Section("About") {
                ListRow("Firmware Version") {
                    Text("1.2.0")
                }
                ListRow("Serial Number") {
                    Text("AAAA")
                }
            }

            Button(action: {
                device.disconnect()
                dismiss()
            }) {
                Text("Disconnect") // TODO do we need this?
                    .frame(maxWidth: .infinity)
            }
                .disabled(device.state != .connected && device.state != .connecting && device.state == .interventionRequired)
        }
            .navigationTitle(device.device.name)
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var battery: some View {
        if let remainingBattery = device.remainingBatteryPercentage {
            Section {
                ListRow("Battery") {
                    Group {
                        Text("\(Int(remainingBattery)) %")
                        batteryIcon(percentage: remainingBattery) // hides accessibility, only text will be shown
                            .foregroundStyle(.primary)
                    }
                }
            } footer: {
                // TODO locale!
                Text("Issues with your battery? [Troubleshooting](https://choosemuse.my.site.com/s/article/Muse-Battery-Troubleshooting?language=en_US)")
            }
        }
    }

    @ViewBuilder private var headbandFit: some View {
        Section {
            if !device.wearingHeadband {
                ListRow("Wearing") {
                    Text("No")
                }
            } else {
                ListRow("Headband Fit") {
                    let fit = device.fit.overallFit
                    Text(fit.localizedStringResource)
                        .foregroundStyle(fit.style)
                }
            }
        } footer: {
            // TODO always show?
            Text("Issues maintaining a good fit? [Troubleshooting](https://choosemuse.my.site.com/s/article/Sensor-Quality-Troubleshooting?language=en_US)")
        }
    }


    init(device: ConnectedDevice) {
        self.device = device
    }


    @ViewBuilder
    func batteryIcon(percentage: Double) -> some View {
        Group {
            if percentage >= 90 {
                Image(systemName: "battery.100")
            } else if percentage >= 65 {
                Image(systemName: "battery.75")
            } else if percentage >= 40 {
                Image(systemName: "battery.50")
            } else if percentage >= 15 {
                Image(systemName: "battery.25")
            } else if percentage > 3 {
                Image(systemName: "battery.25")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
            } else {
                Image(systemName: "battery.0")
                    .foregroundColor(.red)
            }
        }
            .accessibilityHidden(true)
    }
}


#if DEBUG
struct EEGDeviceDetails_Previews: PreviewProvider {
    @StateObject static var model = EEGViewModel(mock: MockEEGDevice(name: "Mock Device", model: "Mock", state: .connected))

    static var previews: some View {
        if let device = model.activeDevice {
            NavigationStack {
                EEGDeviceDetails(device: device)
            }
        }
    }
}
#endif
