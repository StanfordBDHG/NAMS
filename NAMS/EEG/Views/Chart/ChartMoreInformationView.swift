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


struct ChartMoreInformationView: View {
    private let session: EEGRecordingSession


    @MainActor private var averageSampleRate: Int {
        Int(Double(session.totalSamples) / Date.now.timeIntervalSince(session.startDate))
    }

    var body: some View {
        List {
            ListRow("Average Samplerate") {
                Text("\(averageSampleRate) Hz")
            }
        }
            .navigationTitle("More Information")
            .navigationBarTitleDisplayMode(.inline)
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
                ChartMoreInformationView(session: session)
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
