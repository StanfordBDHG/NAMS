//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR
import SpeziFirestore


// SpeziFHIR defines the Observation Model which collides with Apples Observation framework naming

extension PatientListModel {
    func add(response: QuestionnaireResponse) async throws {
        guard let questionnaireId = response.questionnaire?.value?.url.absoluteString else {
            Self.logger.error("Failed to retrieve questionnaire id for response!")
            throw QuestionnaireError.unexpectedFormat
        }

        guard let activePatient,
              let patientId = activePatient.id else {
            Self.logger.error("Couldn't save questionnaire response \(questionnaireId). No patient found!")
            throw QuestionnaireError.missingPatient
        }

        guard let questionnaire = PatientQuestionnaire.all.first(where: { $0.questionnaire.url?.value?.url.absoluteString == questionnaireId }) else {
            Self.logger.error("Failed to match questionnaire response with id \(questionnaireId) to any of our local questionnaires.")
            throw QuestionnaireError.failedQuestionnaireMatch
        }

        do {
            try await completedQuestionnairesCollection(patientId: patientId)
                .addDocument(from: CompletedQuestionnaire(internalQuestionnaireId: questionnaire.id, questionnaireResponse: response))
        } catch {
            Self.logger.error("Failed to save questionnaire response for questionnaire \(questionnaireId)!")
            throw FirestoreError(error)
        }
    }
}
