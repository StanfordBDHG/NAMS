//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import Spezi
@_spi(TestingSupport)
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

    @State private var recordingSession: EEGRecordingSession?

    var body: some View {
        ZStack {
            if !deviceCoordinator.isConnected {
                ContentUnavailableView {
                    Label("No Device", systemImage: "brain.head.profile")
                } description: {
                    Text("Please connect to a\nnearby EEG headband first.")
                }
                    .navigationTitle("Recording")
                    .navigationBarTitleDisplayMode(.inline)
            } else if let recordingSession {
                EEGRecordingSessionView(session: recordingSession)
            } else {
                StartRecordingView($recordingSession)
            }
        }
            .toolbar {
                // the EEGChartsView places it's own Cancel button!
                if !deviceCoordinator.isConnected || recordingSession == nil {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
    }

    init() {}
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.accountId = UUID().uuidString
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return NavigationStack {
        AutoStartRecordingView { _ in
            EEGRecordingView()
        }
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
            }
    }
}

#Preview {
    var details = AccountDetails()
    details.accountId = UUID().uuidString
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return NavigationStack {
        EEGRecordingView()
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
            }
    }
}

#Preview {
    NavigationStack {
        EEGRecordingView()
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(service: InMemoryAccountService())
                EEGRecordings()
                DeviceCoordinator()
                PatientListModel()
            }
    }
}
#endif
