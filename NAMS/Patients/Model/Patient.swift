//
//  Patient.swift
//  NAMS
//
//  Created by Andreas Bauer on 11.06.23.
//

import Foundation

struct Patient: Identifiable, Hashable { // TODO hashable implementation
    let id: String
    let firstName: String
    let lastName: String
    let active: Bool

    init(id: String, firstName: String, lastName: String, active: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.active = active
    }
}
