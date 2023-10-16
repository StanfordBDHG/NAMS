//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct EEGRecording: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject private var eegModel: EEGViewModel
    @State private var frequency: EEGFrequency = .theta

    private var pickerFrequencies: [EEGFrequency] {
        EEGFrequency.allCases.filter { eegModel.activeDevice?.measurements.keys.contains($0) ?? false }
    }

    var body: some View {
        List {
            if let activeDevice = eegModel.activeDevice {
                frequencyPicker

                eegCharts(active: activeDevice)

                Section {
                    Button(role: .destructive, action: {
                        activeDevice.measurements = [:]
                    }) {
                        Text("RESET")
                    }
                }
            } else {
                Text("NO_DEVICE_CONNECTED")
                    .bold()
                Text("CONNECT_NEARBY_HINT")
            }
        }
            .navigationTitle("EEG_RECORDING")
            .toolbar {
                Button("CLOSE") {
                    dismiss()
                }
            }
    }

    @ViewBuilder private var frequencyPicker: some View {
        Section {
            Picker("FREQUENCY", selection: $frequency) {
                ForEach(pickerFrequencies) { frequency in
                    Text(frequency.localizedStringResource)
                        .tag(frequency)
                }
            }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .padding(.bottom, -10)
        }
    }

    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }


    @ViewBuilder
    private func eegCharts(active activeDevice: ConnectedDevice) -> some View {
        Section {
            let measurements = activeDevice.measurements[frequency, default: []]
            let suffix = measurements.suffix(frequency == .all ? 800 : 100)
            let baseTime = measurements.first?.timestamp.timeIntervalSince1970

            VStack {
                EEGChart(measurements: suffix, for: .tp9, baseTime: baseTime)
                EEGChart(measurements: suffix, for: .af7, baseTime: baseTime)
                EEGChart(measurements: suffix, for: .af8, baseTime: baseTime)
                EEGChart(measurements: suffix, for: .tp10, baseTime: baseTime)
            }
        }
            .listRowBackground(Color.clear)
    }
}


#if DEBUG
struct EEGMeasurement_Previews: PreviewProvider {
    static let connectedDevice = MockEEGDevice(name: "Device 1", model: "Mock", state: .connected)

    @StateObject static var connectedModel = EEGViewModel(mock: connectedDevice)
    @StateObject static var model = EEGViewModel(deviceManager: MockDeviceManager())

    static var previews: some View {
        NavigationStack {
            EEGRecording(eegModel: connectedModel)
        }

        NavigationStack {
            EEGRecording(eegModel: model)
        }
    }
}
#endif
