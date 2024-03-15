//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum PredefinedElectrodeLocation: String, Hashable {
    case cap
    case paper
    case custom
}


extension PredefinedElectrodeLocation: CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .cap:
            "Cap"
        case .paper:
            "Paper"
        case .custom:
            "Custom"
        }
    }
}
