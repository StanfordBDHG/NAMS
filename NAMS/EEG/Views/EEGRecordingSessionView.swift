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


struct EEGRecordingSessionView: View {
    private let session: EEGRecordingSession

    @Environment(\.dismiss)
    private var dismiss

    @Environment(EEGRecordings.self)
    private var eegModel
    @Environment(PatientListModel.self)
    private var patientList

    @AppStorage(StorageKeys.displayInterval)
    private var displayInterval: TimeInterval = 7.0
    @AppStorage(StorageKeys.valueInterval)
    private var valueInterval: Int = 6000

    @State private var presentingChartControls = false
    @State private var presentingMoreInformation = false
    @State private var presentCancelConfirmation = false

    /// Popover point for iPad modal view.
    private var popoverUnitPoint: UnitPoint {
        .init(x: 0.95, y: 0)
    }

    @MainActor private var isRecording: Bool {
        switch session.recordingState {
        case .preparing, .inProgress:
            true
        default:
            false
        }
    }

    @MainActor private var isRetryAble: Bool {
        switch session.recordingState {
        case .fileUploadFailed, .taskUploadFailed:
            true
        default:
            false
        }
    }

    @MainActor private var isCompleted: Bool {
        if case .completed = session.recordingState {
            true
        } else {
            false
        }
    }

    var body: some View {
        @Bindable var session = session
        ScrollView {
            RecordingStateHeader(recordingState: $session.recordingState)

            ForEach(session.livePreview(interval: displayInterval), id: \.label) { measurement in
                EEGChart(signal: measurement, displayedInterval: displayInterval, valueInterval: valueInterval)
            }
                .padding([.leading, .trailing], 16)
        }
            .interactiveDismissDisabled(!isCompleted)
            .toolbar {
                if isRecording {
                    ToolbarItemGroup(placement: .secondaryAction) {
                        Button("Edit Chart Layout", systemImage: "pencil") {
                            presentingChartControls = true
                        }
                        Button("More Information", systemImage: "info.square") {
                            presentingMoreInformation = true
                        }
                    }
                }

                if case .completed = session.recordingState {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                } else if case .saving = session.recordingState {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                } else {
                    if isRetryAble {
                        ToolbarItem(placement: .primaryAction) {
                            AsyncButton("Try again") { @MainActor in
                                await eegModel.retryUpload()
                            }
                        }
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentCancelConfirmation = true
                        }
                    }
                }
            }
            .task {
                await eegModel.runRecordingAndSave() // long-running task!
            }
            .popover(isPresented: $presentingChartControls, attachmentAnchor: .point(popoverUnitPoint), arrowEdge: .top) {
                ChangeChartLayoutView(displayInterval: $displayInterval, valueInterval: $valueInterval)
                    .chartPopoverLayout()
            }
            .popover(isPresented: $presentingMoreInformation, attachmentAnchor: .point(popoverUnitPoint), arrowEdge: .top) {
                ChartMoreInformationView(session: session)
                    .chartPopoverLayout()
            }
            .confirmationDialog("Do you want to cancel the ongoing recording?", isPresented: $presentCancelConfirmation, titleVisibility: .visible) {
                Button("Cancel Recording", role: .destructive) {
                    dismiss()
                }
                Button("Continue Recording", role: .cancel) {}
            }
    }


    init(session: EEGRecordingSession) {
        self.session = session
    }
}


extension View {
    @ViewBuilder
    fileprivate func chartPopoverLayout() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            NavigationStack {
                self
            }
            .presentationDetents([.fraction(0.35), .large])
        } else {
            self
                .frame(minWidth: 450, minHeight: 250) // frame for the popover
        }
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
                EEGRecordingSessionView(session: session)
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
