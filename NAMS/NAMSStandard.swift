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
    enum TemplateApplicationStandardError: Error {
        case userNotAuthenticatedYet
    }

    private let logger = Logger(subsystem: "TemplateApplication", category: "Standard")

    @Dependency var mockWebService = MockWebService()

    @AccountReference var account


    private var userDocumentReference: DocumentReference {
        get async throws {
            guard let user = await account.details else {
                throw TemplateApplicationStandardError.userNotAuthenticatedYet
            }

            return Firestore.firestore().collection("users").document(user.accountId)
        }
    }

    func add(response: ModelsR4.QuestionnaireResponse) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString

        guard !FeatureFlags.disableFirebase else {
            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            try? await mockWebService.upload(path: "questionnaireResponse/\(id)", body: jsonRepresentation)
            return
        }

        do {
            try await userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            logger.error("Could not store questionnaire response: \(error)")
        }
    }

    func deletedAccount() async throws {
        // delete all user associated data
    }
}
