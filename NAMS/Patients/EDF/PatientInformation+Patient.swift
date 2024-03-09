//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


extension PatientInformation {
    init(from patient: Patient) {
        let sex: PatientInformation.Sex?
        if let sex0 = patient.sex {
            sex = .init(from: sex0)
        } else {
            sex = nil
        }

        self.init(
            code: patient.code,
            sex: sex,
            birthdate: patient.birthdate,
            name: patient.name.formatted(.name(style: .medium))
        )
    }
}
