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
    @State private var frequency: EEGFrequency = .all

    var body: some View {
        List {
            if let activeMuse = eegModel.activeDevice {
                Text("Device: \(activeMuse.device.model) - \(activeMuse.device.name)")

                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach([EEGFrequency.theta, .alpha, .beta, .gamma]) { frequency in // TODO enable all at some point
                            Text(frequency.localizedStringResource).tag(frequency) // TODO line break
                        }
                    }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, -10)
                }

                Section {
                    let measurements = activeMuse.measurements[frequency, default: []]
                    let suffix = measurements.suffix(frequency == .all ? 800 : 100) // TODO sample rate?
                    let baseTime = measurements.first?.timestamp.timeIntervalSince1970

                    // if let baseTime, let lastTime = measurements.last?.timestamp.timeIntervalSince1970 {
                    //    let asd = print("max time! \(lastTime - baseTime)")
                    // }

                    VStack {
                        EEGChart(measurements: suffix, for: .tp9, baseTime: baseTime)
                        EEGChart(measurements: suffix, for: .af7, baseTime: baseTime)
                        EEGChart(measurements: suffix, for: .af8, baseTime: baseTime)
                        EEGChart(measurements: suffix, for: .tp10, baseTime: baseTime)
                    }
                }
                    .listRowBackground(Color.clear)

                Section {
                    Button(role: .destructive, action: {
                        activeMuse.measurements = [:]
                    }) {
                        Text("Reset")
                    }
                }
            } else {
                Text("No Device connected!") // TODO optimize
            }
        }
            .navigationTitle("EEG Recording")
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
    }

    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }
}


#if DEBUG
struct EEGMeasurement_Previews: PreviewProvider {
    @StateObject static var model = EEGViewModel(deviceManager: MockDeviceManager())
    static var previews: some View {
        NavigationStack {
            EEGRecording(eegModel: model)
        }
    }
}
#endif
