//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
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
