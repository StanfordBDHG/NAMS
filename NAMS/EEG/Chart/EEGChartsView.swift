//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI


struct EEGChartsView: View {
    private let session: EEGRecordingSession

    @Environment(\.dismiss)
    private var dismiss

    @Environment(EEGRecordings.self)
    private var eegModel
    @Environment(PatientListModel.self)
    private var patientList

    @AppStorage("nams.eeg.time-interval")
    private var displayInterval: TimeInterval = 7.0
    @AppStorage("nams.eeg.value-interval")
    private var valueInterval: Int = 300
    // TODO: @State private var viewState: ViewState = .idle

    @State private var presentingChartControls = false

    let recordingTime = Date()...Date().addingTimeInterval(EEGRecordingSession.recordingDuration + 1.0)

    private var popoverUnitPoint: UnitPoint {
        .init(x: 0.95, y: 0)
    }

    private var recordingFinished: Bool {
        recordingTime.upperBound <= .now
    }
    /*
     // TODO: remove!
     AsyncButton(state: $viewState) {
     // simulate a completed task for now
     let task = CompletedTask(taskId: MeasurementTask.eegMeasurement.id, content: .eegRecording(recordingId: session.id))
     try await patientList.add(task: task)
     dismiss()
     } label: {
     Text("Mark completed")
     }
     */

    private var failedToSave: Bool {
        true
    }

    // TODO: start button (+ countdown)
    var body: some View {
        // TODO: swifltint?
        ScrollView { // swiftlint:disable:this closure_body_length
            VStack {
                if recordingFinished {
                    if case .error = eegModel.recordingState {
                        Text("Upload Failed")
                            .font(.title)
                            .bold()
                        // TODO: error message below?

                        Button("Try again") {

                        }
                    } else {
                        Text("Recording Finished")
                            .font(.title)
                            .bold()
                        Text("Saving ...")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .bold()
                            .toolbar {
                                if case .processing = eegModel.recordingState {
                                    // TODO: technically we could just add the progress state from firebase here?
                                    ToolbarItem(placement: .primaryAction) {
                                        ProgressView() // TODO: only if actually saving?
                                    }
                                }
                            }
                    }
                } else {
                    Text("In Progress")
                        .font(.title)
                        .bold()
                    (Text("Remaining: ") + Text(timerInterval: recordingTime))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .bold()
                }
            }
                .multilineTextAlignment(.center)
                .padding(.bottom)

            ForEach(session.livePreview(interval: displayInterval), id: \.label) { measurement in
                EEGChart(signal: measurement, displayedInterval: displayInterval, valueInterval: valueInterval)
            }
                .padding([.leading, .trailing], 16)
        }
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Edit Chart Layout", systemImage: "pencil") {
                        presentingChartControls = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: recordingFinished) { // TODO: this relies entierly on SwiftUI updates!
                if recordingFinished {
                    Task { // TODO: cancel task onDisappear?
                        await eegModel.saveRecording()
                    }
                }
            }
            .onDisappear {
                // TODO: support cancelling the session if view gets into background!
                if !recordingFinished {
                    Task {
                        try await eegModel.stopRecordingSession()
                    }
                }
            }
            .interactiveDismissDisabled() // TODO: support cancellation?
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
#Preview {
    let detailsBuilder = AccountDetails.Builder()
        .set(\.accountId, value: UUID().uuidString)
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return NavigationStack {
        AutoStartRecordingView { session in
            if let session {
                EEGChartsView(session: session)
            } else {
                ProgressView()
            }
        }
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(building: detailsBuilder, active: MockUserIdPasswordAccountService())
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
            }
    }
}
#endif
