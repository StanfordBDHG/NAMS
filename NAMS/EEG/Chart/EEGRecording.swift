//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SpeziViews
import SwiftUI


struct EEGRecording: View {
    @Environment(\.dismiss)
    private var dismiss

    private let eegModel: EEGViewModel
    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle
    @State private var frequency: EEGFrequency = .theta

    private var pickerFrequencies: [EEGFrequency] {
        EEGFrequency.allCases.filter { eegModel.recordingSession?.measurements.keys.contains($0) ?? false }
    }

    var body: some View {
        ZStack {
            // TODO: proper state modelling: not conneced, no session, session
            if let session = eegModel.recordingSession {
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

                        Button(role: .destructive, action: {
                            session.measurements = [:]
                        }) {
                            Text("Reset")
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    NoInformationText {
                        Text("No Device connected!")
                    } caption: {
                        Text("Please connect to a nearby EEG headband first.")
                    }
                    Button("Start Recording Session") {
                        eegModel.startRecordingSession()
                    }
                }
            }
        }
            .navigationTitle("EEG Recording")
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
            let suffix = measurements.suffix(frequency == .all ? 800 : 100) // TODO: adjust dynamically!
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

    static let connectedModel = EEGViewModel(mock: connectedDevice)
    static let model = EEGViewModel(deviceManager: MockDeviceManager())

    static var previews: some View {
        NavigationStack {
            EEGRecording(eegModel: connectedModel)
                .environment(PatientListModel())
        }

        NavigationStack {
            EEGRecording(eegModel: model)
                .environment(PatientListModel())
        }
    }
}
#endif
