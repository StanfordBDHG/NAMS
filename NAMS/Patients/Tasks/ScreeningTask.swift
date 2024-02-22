//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

#if canImport(SpeziQuestionnaire)
import Foundation
import SpeziQuestionnaire


struct ScreeningTask: PatientTask {
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


extension ScreeningTask {
    static let all: [ScreeningTask] = [.mChatRF]

    static var mChatRF: ScreeningTask = {
        ScreeningTask(
            id: "m_chat_rf_1.0",
            title: "M-CHAT R/F",
            description: "The Modified Checklist for Autism in Toddlers, Revised with Follow-Up.",
            questionnaire: .mChatRF,
            expectedCompletionMinutes: "5-10"
        )
    }()
}
#endif
