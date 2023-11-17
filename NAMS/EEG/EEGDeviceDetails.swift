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
    @Environment(\.locale)
    private var locale

    private let device: ConnectedDevice

    var body: some View {
        List {
            if case let .interventionRequired(message) = device.state {
                interventionRequiredHeader(message: message)
            }


            battery

            headbandFit

            if !device.aboutInformation.isEmpty {
                Section("About") {
                    ForEach(device.aboutInformation.elements, id: \.key) { element in
                        ListRow(element.key) {
                            Text(verbatim: element.value.description)
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
            .navigationTitle(Text(verbatim: device.device.model))
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var battery: some View {
        if let remainingBattery = device.remainingBatteryPercentage {
            Section {
                ListRow("BATTERY") {
                    BatteryIcon(percentage: Int(remainingBattery))
                }
            } footer: {
                let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
                Text("PROBLEMS_BATTERY_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Muse-Battery-Troubleshooting?language=\(locale.identifier))")
            }
        }
    }

    @ViewBuilder private var headbandFit: some View {
        Section {
            ListRow("WEARING") {
                if device.wearingHeadband {
                    Text("Yes")
                } else {
                    Text("No")
                }
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
            let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
            Text("PROBLEMS_HEADBAND_FIT_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Sensor-Quality-Troubleshooting?language=\(locale.identifier))")
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
            Text("\(image) ", comment: "Image prefix placeholder") // this cannot verbatim
                + Text("INTERVENTION_REQUIRED_TITLE")
                    .fontWeight(.semibold)
                + Text(verbatim: "\n")
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
}


#if DEBUG
#Preview {
    let model = EEGViewModel(mock: MockEEGDevice(name: "Mock Device", model: "Mock", state: .connected))
    return NavigationStack {
        EEGDeviceDetails(device: model.activeDevice!) // swiftlint:disable:this force_unwrapping
    }
}

#Preview {
    let modelIntervention = EEGViewModel(mock: MockEEGDevice(
        name: "Mock Device",
        model: "Mock",
        state: .interventionRequired("INTERVENTION_MUSE_FIRMWARE")
    ))
    return NavigationStack {
        EEGDeviceDetails(device: modelIntervention.activeDevice!) // swiftlint:disable:this force_unwrapping
    }
}
#endif
