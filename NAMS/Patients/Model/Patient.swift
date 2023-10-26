//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestoreSwift
import Foundation


struct Patient: Codable, Identifiable {
    @DocumentID var id: String?
    let name: PersonNameComponents
    let note: String?

    var firstLetter: Character? {
        name.formatted(.name(style: .medium)).first
    }


    // swiftlint:disable:next function_default_parameter_at_end
    init(id: String? = nil, name: PersonNameComponents, note: String? = nil) {
        self.id = id
        self.name = name
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
