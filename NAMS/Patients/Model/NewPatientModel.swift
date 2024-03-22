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
    var code: String = ""
    var sex: Patient.Sex = .notDisclosed {
        didSet {
            sexDidChange = true
        }
    }
    var birthdate: Date = .now
    var notes: String = ""

    private var sexDidChange = false

    var shouldAskForCancelConfirmation: Bool {
        !((name.givenName ?? "").isEmpty
          && (name.familyName ?? "").isEmpty
          && notes.isEmpty
          && !sexDidChange
          && code.isEmpty)
    }
}


extension Patient {
    init(from model: NewPatientModel) {
        let code = model.code.isEmpty ? nil : model.code
        let notes = model.notes.isEmpty ? nil : model.notes

        self.init(name: model.name, code: code, sex: model.sex, birthdate: model.birthdate, note: notes)
    }
}
