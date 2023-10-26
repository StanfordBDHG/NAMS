//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR


extension Questionnaire {
    static func questionnaire(withName name: String, bundle: Foundation.Bundle) -> Questionnaire {
        guard let resourceURL = bundle.url(forResource: name, withExtension: "json") else {
            preconditionFailure("Could not find the questionnaire \"\(name).json\" in the bundle.")
        }

        do {
            let resourceData = try Data(contentsOf: resourceURL)
            return try JSONDecoder().decode(Questionnaire.self, from: resourceData)
        } catch {
            preconditionFailure("Could not decode the FHIR questionnaire named \"\(name).json\": \(error)")
        }
    }
}


extension Questionnaire {
    static var mChatRF: Questionnaire = {
        questionnaire(withName: "M_CHAT_R_F-en-US-v1.0", bundle: .main)
    }()
}
