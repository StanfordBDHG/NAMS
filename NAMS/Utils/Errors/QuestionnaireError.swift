//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum QuestionnaireError: LocalizedError {
    case unexpectedFormat
    case missingPatient
    case failedQuestionnaireMatch

    private var errorDescriptionResource: LocalizedStringResource {
        "Failed to complete Questionnaire"
    }

    var errorDescription: String? {
        String(localized: errorDescriptionResource)
    }

    private var failureReasonResource: LocalizedStringResource {
        switch self {
        case .unexpectedFormat:
            return "Unexpected format of the questionnaire response!"
        case .missingPatient:
            return "There was no selected patient found!"
        case .failedQuestionnaireMatch:
            return "Failed to associate response with original questionnaire!"
        }
    }

    var failureReason: String? {
        String(localized: failureReasonResource)
    }
}
