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
        .init("Failed to complete Questionnaire", comment: "Error Description")
    }

    var errorDescription: String? {
        String(localized: errorDescriptionResource)
    }

    private var failureReasonResource: LocalizedStringResource {
        switch self {
        case .unexpectedFormat:
            return .init("Unexpected format of the questionnaire response!", comment: "Failure Reason")
        case .missingPatient:
            return .init("There was no selected patient found!", comment: "Failure Reason")
        case .failedQuestionnaireMatch:
            return .init("Failed to associate response with original questionnaire!", comment: "Failure Reason")
        }
    }

    var failureReason: String? {
        String(localized: failureReasonResource)
    }
}
