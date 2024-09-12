//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport)
import SpeziAccount
import SpeziBluetooth
import SpeziOnboarding
import SwiftUI


struct StartRecordingView: View {
    @Environment(EEGRecordings.self)
    private var eegModel
    @Environment(Account.self)
    private var account


    @Binding private var recordingSession: EEGRecordingSession?

    var body: some View {
        OnboardingView(
            title: "Start a new Recording",
            subtitle: "Start a new EEG recording session for the currently selected patient.",
            areas: [
                .init(
                    icon: {
                        Image(systemName: "brain.filled.head.profile")
                            .foregroundColor(.pink)
                            .accessibilityHidden(true)
                    },
                    title: "Brain Activity",
                    description: "Collect the patient's brain activity using the connected EEG headband."
                ),
                .init(
                    icon: {
                        Image(systemName: "waveform.path")
                            .foregroundColor(.pink)
                            .accessibilityHidden(true)
                    },
                    title: "Live Visualization",
                    description: "Brain activity is visualized in real time."
                )
            ],
            actionText: "Start Recording",
            action: {
                // button is disabled if no details are present
                if let details = account.details {
                    self.recordingSession = try await eegModel.createRecordingSession(investigator: details)
                }
            }
        )
            .tint(.pink)
            .disabled(!account.signedIn)
    }


    init(_ recordingSession: Binding<EEGRecordingSession?>) {
        self._recordingSession = recordingSession
    }
}


#if DEBUG
#Preview {
    StartRecordingView(.constant(nil))
        .previewWith(standard: NAMSStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
            EEGRecordings()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
        }
}
#endif
