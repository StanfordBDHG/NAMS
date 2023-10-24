//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation


@Observable
class PatientSearchModel {
    var searchText: String = ""
    var searchToken: [SearchToken] = []
    var suggestedTokens: [SearchToken] = []


    func search(in patients: [Patient]) -> [Patient] {
        guard !searchText.isEmpty else {
            return patients
        }

        return patients.filter { patient in
            // TODO optimize search and split the term in tokens?
            patient.name.givenName?.contains(searchText) == true
                || patient.name.familyName?.contains(searchText) == true
        }
    }
}
