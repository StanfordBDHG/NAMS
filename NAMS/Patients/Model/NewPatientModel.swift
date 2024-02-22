//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Observation


@Observable
class NewPatientModel {
    var name = PersonNameComponents()
    var notes: String = ""

    
    var shouldAskForCancelConfirmation: Bool {
        !((name.givenName ?? "").isEmpty && (name.familyName ?? "").isEmpty && notes.isEmpty)
    }
}


extension Patient {
    init(from model: NewPatientModel) {
        self.name = model.name
        self.note = model.notes
    }
}
