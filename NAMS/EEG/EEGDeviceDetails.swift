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
            if case let .interventionRequired(message) = device.state {
                interventionRequiredHeader(message: message)
            }


            battery

            headbandFit


            if !device.aboutInformation.isEmpty {
                Section("ABOUT") {
                    ForEach(device.aboutInformation.elements, id: \.key) { element in
                        ListRow(element.key) {
                            Text(element.value.description)
                        }
                    }
                }
            }

            Button(action: {
                device.disconnect()
                dismiss()
            }) {
                Text("DISCONNECT")
                    .frame(maxWidth: .infinity)
            }
                .disabled(!device.state.associatedConnection)
        }
            .navigationTitle(device.device.name)
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var battery: some View {
        if let remainingBattery = device.remainingBatteryPercentage {
            Section {
                ListRow("BATTERY") {
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
            ListRow("WEARING") {
                Text(device.wearingHeadband ? "YES" : "NO")
            }
            
            if device.wearingHeadband {
                ListRow("HEADBAND_FIT") {
                    let fit = device.fit.overallFit
                    Text(fit.localizedStringResource)
                        .foregroundStyle(fit.style)
                }
            }
        } header: {
            Text("HEADBAND")
        } footer: {
            Text("Issues maintaining a good fit? [Troubleshooting](https://choosemuse.my.site.com/s/article/Sensor-Quality-Troubleshooting?language=en_US)")
        }
    }


    init(device: ConnectedDevice) {
        self.device = device
    }


    @ViewBuilder
    func interventionRequiredHeader(message: LocalizedStringResource) -> some View {
        VStack {
            // swiftlint:disable:next accessibility_label_for_image
            let image = Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
            Text("\(image) ")
                + Text("INTERVENTION_REQUIRED_TITLE")
                    .fontWeight(.semibold)
                + Text("\n")
                + Text(message)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .accessibilityRepresentation {
                Text("INTERVENTION_REQUIRED_PREFIX \(message)")
            }
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

    @StateObject static var modelIntervention = EEGViewModel(mock: MockEEGDevice(
        name: "Mock Device",
        model: "Mock",
        state: .interventionRequired("INTERVENTION_MUSE_FIRMWARE")
    ))

    static var previews: some View {
        if let device = model.activeDevice {
            NavigationStack {
                EEGDeviceDetails(device: device)
            }
        }

        if let device = modelIntervention.activeDevice {
            NavigationStack {
                EEGDeviceDetails(device: device)
            }
        }
    }
}
#endif
