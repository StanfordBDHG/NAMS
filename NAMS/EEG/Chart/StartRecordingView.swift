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
    private let eegModel: EEGViewModel
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?

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
                eegModel.startRecordingSession()
                if let biopot, biopot.connected {
                    Task {
                        await biopot.enableRecording()
                    }
                }
            }
        )
        .tint(.pink)
    }


    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }
}


#if DEBUG
#Preview {
    StartRecordingView(eegModel: EEGViewModel(mock: MockEEGDevice(name: "Device 1", model: "Mock", state: .connected)))
        .previewWith {
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
        }
}
#endif
