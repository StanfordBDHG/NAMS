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

    @Environment(Account.self)
    private var account
    @Environment(EEGRecordings.self)
    private var model

    @State private var recordingSession: EEGRecordingSession?

    var body: some View {
        content(recordingSession)
            .task {
                guard let details = account.details else {
                    preconditionFailure("Account not present")
                }
                do {
                    recordingSession = try await model.createRecordingSession(investigator: details)
                } catch {
                    print("Failed to start recording: \(error)")
                }
            }
    }


    init(@ViewBuilder content: @escaping (EEGRecordingSession?) -> Content) {
        self.content = content
    }
}
#endif
