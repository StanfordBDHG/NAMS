//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import FirebaseFirestoreSwift
import Foundation


struct Patient: Codable, Identifiable {
    @DocumentID var id: String?
    let name: PersonNameComponents

    /// Patient code.
    let code: String?
    let sex: Sex?
    let birthdate: Date?

    let note: String?

    var firstLetter: Character? {
        name.formatted(.name(style: .medium)).first
    }


    // swiftlint:disable:next function_default_parameter_at_end
    init(
        id: String? = nil,
        name: PersonNameComponents,
        code: String? = nil,
        sex: Sex? = nil,
        birthdate: Date? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.sex = sex
        self.birthdate = birthdate
        self.note = note
    }


    func isSelectedPatient(active patientId: String?) -> Bool {
        guard let id else {
            return false
        }

        return id == patientId
    }
}


extension Patient: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Patient {
    enum Sex: String, CaseIterable, Identifiable, Codable, CustomLocalizedStringResourceConvertible {
        case female
        case male
        case other
        case notDisclosed

        var id: String {
            rawValue
        }


        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .female:
                "Female"
            case .male:
                "Male"
            case .other:
                "Other"
            case .notDisclosed:
                "Not Disclosed"
            }
        }
    }
}
