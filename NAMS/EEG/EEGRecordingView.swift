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
                    .navigationTitle("Recording")
                    .navigationBarTitleDisplayMode(.inline)
            } else if let session = eegModel.recordingSession {
                EEGChartsView(session: session)
            } else {
                StartRecordingView()
            }
        }
            .toolbar {
                // the EEGChartsView places it's own Cancel button!
                if !deviceCoordinator.isConnected || eegModel.recordingSession == nil {
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
    let detailsBuilder = AccountDetails.Builder()
        .set(\.accountId, value: UUID().uuidString)
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return NavigationStack {
        AutoStartRecordingView { _ in
            EEGRecordingView()
        }
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(building: detailsBuilder, active: MockUserIdPasswordAccountService())
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
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
            .previewWith(standard: NAMSStandard()) {
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
            .previewWith(standard: NAMSStandard()) {
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
