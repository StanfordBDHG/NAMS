//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


extension PatientInformation {
    init(from patient: Patient) {
        let sex: PatientInformation.Sex?
        if let sex0 = patient.sex {
            sex = .init(from: sex0)
        } else {
            sex = nil
        }

        // We have a maximum string length of 80 chars.
        // There are always:
        // - 1 char for sex
        // - 3 spaces for separators
        // - 10 chars for birthdate
        // - minimum 2 chars for abbreviated names
        // => patient code can have a maximum length of 64

        let code = patient.code.map { code in
            String(code.prefix(64))
        }

        let nameStyle: PersonNameComponents.FormatStyle.Style
        if (1 + 3 + (code?.count ?? 1) + (patient.birthdate != nil ? 10 : 1) + patient.name.formatted(.name(style: .medium)).count) > 80 {
            // assumption of 2 chars breaks with certain scripts (e.g., not supported in Arabic etc).
            // However, EDF only supports ASCII anyways, so we are fine?
            nameStyle = .abbreviated
        } else {
            nameStyle = .medium
        }

        self.init(
            code: code,
            sex: sex,
            birthdate: patient.birthdate,
            name: patient.name.formatted(.name(style: nameStyle))
        )
    }
}
