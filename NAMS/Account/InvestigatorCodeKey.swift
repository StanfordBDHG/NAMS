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


private struct InvestigatorCodeEntry: DataEntryView {
    @Binding var value: String

    init(_ value: Binding<String>) {
        _value = value
    }

    var body: some View {
        VerifiableTextField(AccountKeys.investigatorCode.name, text: $value)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .validate(input: value, rules: .investigatorCodeMaxLength)
    }
}


extension AccountDetails {
    @AccountKey(
        name: "Investigator Code",
        category: .personalDetails,
        as: String.self,
        entryView: InvestigatorCodeEntry.self
    )
    var investigatorCode: String?
}



@KeyEntry(\.investigatorCode)
extension AccountKeys {
}


extension ValidationRule {
    fileprivate static var investigatorCodeMaxLength: ValidationRule {
        ValidationRule(rule: { input in
            input.count <= 30
        }, message: "The investigator code cannot be longer than 30 characters.")
    }
}
