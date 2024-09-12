//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport)
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
    var details = AccountDetails()
    details.accountId = UUID().uuidString
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return NavigationStack {
        AutoStartRecordingView { session in
            if let session {
                ChartMoreInformationView(session: session)
            } else {
                ProgressView()
            }
        }
            .previewWith(standard: NAMSStandard()) {
                AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
                EEGRecordings()
                DeviceCoordinator(mock: .mock(MockDevice(name: "Mock Device 1", state: .connected)))
                PatientListModel(mock: Patient(id: UUID().uuidString, name: PersonNameComponents(givenName: "Leland", familyName: "Stanford")))
            }
    }
}
#endif
