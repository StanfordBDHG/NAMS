//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum EEGFrequency: String, CaseIterable, Identifiable, CustomLocalizedStringResourceConvertible {
    case all
    // TODO list all or just what we are using? = delta?
    case theta
    case alpha
    case beta
    case gamma

    
    var id: String {
        rawValue
    }


    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .all:
            return "All"
        case .theta:
            return "Theta"
        case .alpha:
            return "Alpha"
        case .beta:
            return "Beta"
        case .gamma:
            return "Gamma"
        }
    }
}
