//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziQuestionnaire


struct PatientQuestionnaire: Identifiable {
    let id: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    let questionnaire: Questionnaire

    let tileType: TileType = .questionnaire
    let expectedCompletionMinutes: String

    init(
        id: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        questionnaire: Questionnaire,
        expectedCompletionMinutes: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.questionnaire = questionnaire
        self.expectedCompletionMinutes = expectedCompletionMinutes
    }
}


extension PatientQuestionnaire {
    static let all: [PatientQuestionnaire] = [.mChatRF]

    static var mChatRF: PatientQuestionnaire = {
        PatientQuestionnaire(
            id: "m_chat_rf_1.0",
            title: "M-CHAT R/F",
            description: "The Modified Checklist for Autism in Toddlers, Revised with Follow-Up.",
            questionnaire: .mChatRF,
            expectedCompletionMinutes: "5-10"
        )
    }()
}
