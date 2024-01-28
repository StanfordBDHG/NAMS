//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseDeviceDetailsView: View {
    private let model: String
    private let state: ConnectionState
    private let deviceInformation: MuseDeviceInformation
    private let disconnectClosure: () -> Void

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.locale)
    private var locale

    var body: some View {
        List {
            if case let .interventionRequired(message) = state {
                interventionRequiredHeader(message: message)
            }


            battery

            headbandFit

            Section("About") {
                ListRow("FIRMWARE_VERSION") {
                    Text(verbatim: deviceInformation.firmwareVersion)
                }
                ListRow("SERIAL_NUMBER") {
                    Text(verbatim: deviceInformation.serialNumber)
                }
            }

            Button(action: {
                disconnectClosure()
                dismiss()
            }) {
                Text("DISCONNECT")
                    .frame(maxWidth: .infinity)
            }
                .disabled(!state.associatedConnection)
        }
            .navigationTitle(Text(verbatim: model))
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var battery: some View {
        if let remainingBattery = deviceInformation.remainingBatteryPercentage {
            Section {
                ListRow("BATTERY") {
                    BatteryIcon(percentage: Int(remainingBattery))
                }
            } footer: {
                // TODO: hint separate view!
                let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
                Text("PROBLEMS_BATTERY_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Muse-Battery-Troubleshooting?language=\(locale.identifier))")
            }
        }
    }

    @ViewBuilder private var headbandFit: some View {
        Section {
            ListRow("WEARING") {
                if deviceInformation.wearingHeadband {
                    Text("Yes")
                } else {
                    Text("No")
                }
            }
            
            if deviceInformation.wearingHeadband,
               let fit = deviceInformation.fit {
                ListRow("HEADBAND_FIT") { // TODO: detailed fit!
                    let overallFit = fit.overallFit
                    Text(overallFit.localizedStringResource)
                        .foregroundStyle(overallFit.style)
                }
            }
        } header: {
            Text("HEADBAND")
        } footer: {
            // TODO: hint separate view!
            let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
            Text("PROBLEMS_HEADBAND_FIT_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Sensor-Quality-Troubleshooting?language=\(locale.identifier))")
        }
    }


    init(model: String, state: ConnectionState, _ deviceInformation: MuseDeviceInformation, disconnect: @escaping () -> Void) {
        self.model = model
        self.state = state
        self.deviceInformation = deviceInformation
        self.disconnectClosure = disconnect
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
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .connected,
            .init(serialNumber: "0xAABBCCDD", firmwareVersion: "1.0", remainingBatteryPercentage: 75)
        ) {
            print("Disconnect Device")
        }
    }
}


#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .connected,
            .init(
                serialNumber: "0xAABBCCDD",
                firmwareVersion: "1.0",
                remainingBatteryPercentage: 75,
                wearingHeadband: true,
                fit: HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .poor, tp10Fit: .good)
            )
        ) {
            print("Disconnect Device")
        }
    }
}

#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .interventionRequired("INTERVENTION_MUSE_FIRMWARE"),
            .init(serialNumber: "0xAABBCCDD", firmwareVersion: "1.0", remainingBatteryPercentage: 75)
        ) {
            print("Disconnect Device")
        }
    }
}
#endif
