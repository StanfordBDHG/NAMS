//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


#if DEBUG
struct AutoStartRecordingView<Content: View>: View {
    private let content: (EEGRecordingSession?) -> Content
    private let autoStop: Bool

    @Environment(Account.self)
    private var account
    @Environment(EEGRecordings.self)
    private var model


    var body: some View {
        content(model.recordingSession)
            .task {
                guard let details = account.details else {
                    preconditionFailure("Account not present")
                }
                do {
                    try await model.startRecordingSession(investigator: details)
                } catch {
                    print("Failed to start recording: \(error)")
                }

                // TODO: try await model.runRecording()
            }
            .onDisappear {
                if autoStop {
                    Task {
                        // TOOD: how to replace??
                        // TODO: await model.cancelRecording()
                    }
                }
            }
    }


    init(autoStop: Bool = true, @ViewBuilder content: @escaping (EEGRecordingSession?) -> Content) {
        self.autoStop = autoStop
        self.content = content
    }
}
#endif
