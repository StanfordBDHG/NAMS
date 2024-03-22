//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


extension PatientInformation.Sex {
    init?(from sex: Patient.Sex) {
        switch sex {
        case .male:
            self = .male
        case .female:
            self = .female
        case .other, .notDisclosed:
            return nil // will just be encoded as an X (=anonymized) in EDF
        }
    }
}
