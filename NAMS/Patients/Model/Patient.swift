//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestoreSwift
import Foundation


struct Patient: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let name: PersonNameComponents
    let note: String?


    init(id: String, name: PersonNameComponents, note: String? = nil) {
        self.id = id
        self.name = name
        self.note = note
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
