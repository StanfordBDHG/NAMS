//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SpeziFoundation
import SpeziValidation
import SwiftUI


struct InvestigatorCodeKey: AccountKey {
    typealias Value = String

    static let name: LocalizedStringResource = "Investigator Code"
    static let category: AccountKeyCategory = .personalDetails
    static let initialValue: InitialValue<String> = .empty("")
}


extension AccountValues {
    var investigatorCode: String? {
        storage[InvestigatorCodeKey.self]
    }
}


extension AccountKeys {
    var investigatorCode: InvestigatorCodeKey.Type {
        InvestigatorCodeKey.self
    }
}


extension InvestigatorCodeKey {
    struct DataEntry: DataEntryView {
        typealias Key = InvestigatorCodeKey

        @Binding var value: String

        init(_ value: Binding<String>) {
            _value = value
        }

        var body: some View {
            VerifiableTextField(Key.name, text: $value)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .validate(input: value, rules: .investigatorCodeMaxLength)
        }
    }
}


extension ValidationRule {
    fileprivate static var investigatorCodeMaxLength: ValidationRule {
        ValidationRule(rule: { input in
            input.count <= 30
        }, message: "The investigator code cannot be longer than 30 characters.")
    }
}
