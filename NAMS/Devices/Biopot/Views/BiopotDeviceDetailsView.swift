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

    @State private var viewState: ViewState = .idle

    @State private var samplingConfigurationPresent = false
    @State private var selectedSamplingConfiguration: UInt16 = 250

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
                if samplingConfigurationPresent {
                    Picker("Samplerate", selection: $selectedSamplingConfiguration) {
                        ForEach(SamplingConfiguration.supportedSamplingRates, id: \.self) { samplerate in
                            Text(verbatim: "\(samplerate) Hz")
                                .tag(samplerate)
                        }
                    }
                }
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
            .viewStateAlert(state: $viewState)
            .onChange(of: biopot.state) {
                if isDisconnected {
                    dismiss()
                }
            }
            .onChange(of: biopot.service.samplingConfiguration?.hardwareSamplingRate, initial: true) {
                if let samplerate = biopot.service.samplingConfiguration?.hardwareSamplingRate {
                    samplingConfigurationPresent = true
                    selectedSamplingConfiguration = samplerate
                } else {
                    samplingConfigurationPresent = false
                }
            }
            .onChange(of: selectedSamplingConfiguration) {
                guard let originalRate = biopot.service.samplingConfiguration?.hardwareSamplingRate else {
                    return // wasn't available
                }

                let selectedSamplingConfiguration = selectedSamplingConfiguration
                guard selectedSamplingConfiguration != originalRate else {
                    return // its the same, no reason to update
                }

                Task {
                    do {
                        try await biopot.service.updateSamplingConfiguration(set: \.hardwareSamplingRate, to: selectedSamplingConfiguration)
                    } catch {
                        viewState = .error(AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to update hardware sampling rate."
                        ))
                        self.selectedSamplingConfiguration = originalRate // reset back to original rate
                    }
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
