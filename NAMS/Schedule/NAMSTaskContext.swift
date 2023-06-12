//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR


/// The context attached to each task in the Neurodevelopment Assessment and Monitoring System (NAMS).
///
/// We currently only support `Questionnaire`s, more cases can be added in the future.
enum NAMSTaskContext: Codable, Identifiable {
    /// The task should display a `Questionnaire`.
    case questionnaire(Questionnaire)
    
    
    var id: Questionnaire.ID {
        switch self {
        case let .questionnaire(questionnaire):
            return questionnaire.id
        }
    }
    
    var actionType: String {
        switch self {
        case .questionnaire:
            return String(localized: "TASK_CONTEXT_ACTION_QUESTIONNAIRE")
        }
    }
}
