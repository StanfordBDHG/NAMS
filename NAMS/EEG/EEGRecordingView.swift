//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import Spezi
import SpeziAccount
import SpeziBluetooth
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct EEGRecordingView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(EEGRecordings.self)
    private var eegModel
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    var body: some View {
        ZStack {
            if !deviceCoordinator.isConnected {
                ContentUnavailableView {
                    Label("No Device", systemImage: "brain.head.profile")
                } description: {
                    Text("Please connect to a\nnearby EEG headband first.")
                }
                    .navigationTitle("EEG Recording")
                    .navigationBarTitleDisplayMode(.inline)
            } else if let session = eegModel.recordingSession {
                EEGChartsView(session: session)
            } else {
                StartRecordingView()
            }
        }
            .onDisappear {
                // TODO: support cancelling the session if view gets into background!
                Task {
                    try await eegModel.stopRecordingSession()
                }
            }
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
    }

    init() {}
}


#if DEBUG
#Preview { // swiftlint:disable:this closure_body_length
    struct AutoStartRecordingView: View {
        @Environment(Account.self)
        private var account
        @Environment(EEGRecordings.self)
        private var model

        var body: some View {
            EEGRecordingView()
                .task {
                    guard let details = account.details else {
                        preconditionFailure("Account not present")
                    }
                    do {
                        try await model.startRecordingSession(investigator: details)
                    } catch {
                        print("Failed to start recording: \(error)")
                    }
                }
                .onDisappear {
                    Task {
                        try await model.stopRecordingSession()
                    }
                }
        }
    }
    let detailsBuilder = AccountDetails.Builder()
        .set(\.accountId, value: UUID().uuidString)
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return NavigationStack {
        AutoStartRecordingView()
            .previewWith {
                AccountConfiguration(building: detailsBuilder, active: MockUserIdPasswordAccountService())
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
                Bluetooth {
                    Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
                }
            }
    }
}

#Preview {
    let detailsBuilder = AccountDetails.Builder()
        .set(\.accountId, value: UUID().uuidString)
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return NavigationStack {
        EEGRecordingView()
            .previewWith {
                AccountConfiguration(building: detailsBuilder, active: MockUserIdPasswordAccountService())
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
            }
    }
}

#Preview {
    NavigationStack {
        EEGRecordingView()
            .previewWith {
                AccountConfiguration {
                    MockUserIdPasswordAccountService()
                }
                EEGRecordings()
                DeviceCoordinator()
                PatientListModel()
            }
    }
}
#endif
