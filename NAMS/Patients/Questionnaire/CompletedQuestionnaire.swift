//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestoreSwift
import SpeziFHIR


struct CompletedQuestionnaire: Codable {
    @DocumentID var id: String?
    let internalQuestionnaireId: String
    let questionnaireResponse: QuestionnaireResponse
}
