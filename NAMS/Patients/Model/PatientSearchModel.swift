//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
import OrderedCollections


@Observable
class PatientSearchModel {
    var searchText: String = ""
    var searchToken: [SearchToken] = []
    var suggestedTokens: [SearchToken] = []


    func search(in patients: OrderedDictionary<Character, [Patient]>) -> OrderedDictionary<Character, [Patient]> {
        guard !searchText.isEmpty else {
            return patients
        }

        return patients.compactMapValues { patients in
            let result = patients.filter { patient in
                patient.name.givenName?.contains(searchText) == true
                || patient.name.familyName?.contains(searchText) == true
            }

            if result.isEmpty {
                return nil
            } else {
                return result
            }
        }
    }
}
