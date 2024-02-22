//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum EEGFrequency: String, CaseIterable, Identifiable, CustomLocalizedStringResourceConvertible {
    case all
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
