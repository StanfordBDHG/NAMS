//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import OSLog
import Spezi
import SpeziAccount
import SpeziFirestore
import SpeziMockWebService
import SpeziQuestionnaire
import SwiftUI


actor NAMSStandard: Standard, ObservableObject, ObservableObjectProvider, QuestionnaireConstraint, AccountNotifyStandard {
    private let logger = Logger(subsystem: "TemplateApplication", category: "Standard")

    @Dependency var mockWebService = MockWebService()

    @AccountReference var account

    /// Indicates whether the necessary authorization to deliver local notifications is already granted.
    var localNotificationAuthorization: Bool {
        get async {
            await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
        }
    }

    /// Presents the system authentication UI to send local notifications if the application is not yet permitted to send local notifications.
    func requestLocalNotificationAuthorization() async throws {
        if await !localNotificationAuthorization {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])

            // Triggers an update of the UI in case the notification permissions are changed
            await MainActor.run {
                self.objectWillChange.send()
            }
        }
    }

    func add(response: ModelsR4.QuestionnaireResponse) async {
        // we handle that directly in PatientTiles view.
    }

    func deletedAccount() async throws {
        // delete all care-provider associated data
    }
}
