//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFirestore
import SpeziQuestionnaire


// SpeziFHIR defines the Observation Model which collides with Apples Observation framework naming

extension PatientListModel {
    func add(response: QuestionnaireResponse) async throws {
        guard let questionnaireId = response.questionnaire?.value?.url.absoluteString else {
            Self.logger.error("Failed to retrieve questionnaire id for response!")
            throw QuestionnaireError.unexpectedFormat
        }

        guard let questionnaire = ScreeningTask.all.first(where: { $0.questionnaire.url?.value?.url.absoluteString == questionnaireId }) else {
            Self.logger.error("Failed to match questionnaire response with id \(questionnaireId) to any of our local questionnaires.")
            throw QuestionnaireError.failedQuestionnaireMatch
        }

        let task = CompletedTask(taskId: questionnaire.id, content: .questionnaireResponse(response))
        try await add(task: task)
    }
}
