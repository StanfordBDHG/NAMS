//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziOnboarding
import SwiftUI


struct StartRecordingView: View {
    @Environment(EEGRecordings.self)
    private var eegModel

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
                try await eegModel.startRecordingSession()
            }
        )
            .tint(.pink)
    }


    init() {
    }
}


#if DEBUG
#Preview {
    StartRecordingView()
        .previewWith {
            EEGRecordings()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
        }
}
#endif
