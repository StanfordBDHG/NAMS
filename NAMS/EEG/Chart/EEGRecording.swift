//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SpeziBluetooth
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct EEGRecording: View {
    @Environment(\.dismiss)
    private var dismiss

    private let eegModel: EEGViewModel
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?
    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle
    @State private var frequency: EEGFrequency = .all

    private var pickerFrequencies: [EEGFrequency] {
        EEGFrequency.allCases.filter { eegModel.recordingSession?.measurements.keys.contains($0) ?? false }
    }

    var body: some View {
        ZStack {
            if !(biopot?.connected ?? false) && eegModel.activeDevice == nil {
                NoInformationText {
                    Text("No Device connected!")
                } caption: {
                    Text("Please connect to a nearby EEG headband first.")
                }
                    .navigationTitle("EEG Recording")
                    .navigationBarTitleDisplayMode(.inline)
            } else if let session = eegModel.recordingSession {
                List {
                    frequencyPicker

                    eegCharts(session: session)

                    Section {
                        AsyncButton(state: $viewState) {
                            // simulate a completed task for now
                            let task = CompletedTask(taskId: MeasurementTask.eegMeasurement.id, content: .eegRecording)
                            try await patientList.add(task: task)
                            dismiss()
                        } label: {
                            Text("Mark completed")
                        }
                    }
                }
                    .navigationTitle("EEG Recording")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                StartRecordingView(eegModel: eegModel)
            }
        }
            .toolbar {
                Button("Close") {
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
    private func eegCharts(session: EEGRecordingSession) -> some View {
        Section {
            let measurements = session.measurements[frequency, default: []]
            let suffix = measurements.suffix(frequency == .all ? 800 : 100)

            if let first = measurements.first {
                let baseTime = first.timestamp.timeIntervalSince1970

                VStack {
                    ForEach(first.channels, id: \.self) { channel in
                        EEGChart(measurements: suffix, for: channel, baseTime: baseTime)
                    }
                }
            }
        }
            .listRowBackground(Color.clear)
    }
}


#if DEBUG
#Preview {
    let device = MockEEGDevice(name: "Device 1", model: "Mock", state: .connected)
    let model = EEGViewModel(mock: device)
    model.startRecordingSession()
    return NavigationStack {
        EEGRecording(eegModel: model)
            .environment(PatientListModel())
            .previewWith {
                Bluetooth {
                    Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
                }
            }
    }
}

#Preview {
    let device = MockEEGDevice(name: "Device 1", model: "Mock", state: .connected)
    return NavigationStack {
        EEGRecording(eegModel: EEGViewModel(mock: device))
            .environment(PatientListModel())
            .previewWith {
                Bluetooth {
                    Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
                }
            }
    }
}

#Preview {
    NavigationStack {
        EEGRecording(eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
            .environment(PatientListModel())
            .previewWith {
                Bluetooth {
                    Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
                }
            }
    }
}
#endif
