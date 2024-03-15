//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct EEGChartsView: View {
    private let session: EEGRecordingSession

    @Environment(\.dismiss)
    private var dismiss

    @Environment(PatientListModel.self)
    private var patientList

    // TODO: configurable value range?
    @AppStorage("nams.eeg.time-interval")
    private var displayInterval: TimeInterval = 7.0 // TODO: configurable?
    @AppStorage("nams.eeg.value-interval")
    private var valueInterval: Int = 300
    @State private var viewState: ViewState = .idle

    @State private var presentingChartControls = false

    let recordingTime = Date()...Date().addingTimeInterval(2*60)

    private var popoverUnitPoint: UnitPoint {
        return .init(x: 0.95, y: 0)
    }

    // TODO: start button (+ countdown)
    var body: some View {
        ScrollView {
            HStack {
                (Text("Remaining: ") + Text(timerInterval: recordingTime))
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: "record.circle")
                    .foregroundColor(.red)
                    .font(.title)
            }

            Section {
                ForEach(session.livePreview(interval: displayInterval), id: \.label) { measurement in
                    EEGChart(signal: measurement, displayedInterval: displayInterval, valueInterval: valueInterval)
                }
            }
                .listRowBackground(Color.clear)

            Section {
                AsyncButton(state: $viewState) {
                    // simulate a completed task for now
                    let task = CompletedTask(taskId: MeasurementTask.eegMeasurement.id, content: .eegRecording(recordingId: session.id))
                    try await patientList.add(task: task)
                    dismiss()
                } label: {
                    Text("Mark completed")
                }
            }
        }
            .padding(.top)
            .padding([.leading, .trailing], 20)
            .navigationTitle("EEG Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Edit Chart Layout", systemImage: "pencil") {
                        presentingChartControls = true
                    }
                }
            }
            .popover(isPresented: $presentingChartControls, attachmentAnchor: .point(popoverUnitPoint), arrowEdge: .top) {
                let view = ChangeChartLayoutView(displayInterval: $displayInterval, valueInterval: $valueInterval)

                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationStack {
                        view
                    }
                        .presentationDetents([.fraction(0.35), .large])
                } else {
                    view
                        .frame(minWidth: 450, minHeight: 250) // frame for the popover
                }
            }
    }


    init(session: EEGRecordingSession) {
        self.session = session
    }
}


#if DEBUG
#Preview { // swiftlint:disable:this closure_body_length
    struct PreviewView: View {
        let patient = Patient(id: "123", name: .init(givenName: "Leland", familyName: "Stanford"), code: "LS123", sex: .male)
        let device = MockDevice(name: "Mock", state: .connected)

        @State private var session: EEGRecordingSession?

        var body: some View {
            ZStack {
                if let session {
                    EEGChartsView(session: session)
                } else {
                    ProgressView()
                }
            }
                .task {
                    do {
                        let id = UUID()
                        let url = try EEGRecordings.createTempRecordingFile(id: id)
                        let session = try EEGRecordingSession(id: id, url: url, patient: patient, device: .mock(device), investigatorCode: "SwiftUI")
                        try device.startRecording(session)
                        self.session = session
                    } catch {
                        print("Failed to start recording: \(error)")
                    }
                }
                .onDisappear {
                    do {
                        try device.stopRecording()
                    } catch {
                        print("Failed to stop recording: \(error)")
                    }
                }
        }
    }

    return NavigationStack {
        PreviewView()
    }
        .previewWith {
            PatientListModel()
        }
}
#endif
