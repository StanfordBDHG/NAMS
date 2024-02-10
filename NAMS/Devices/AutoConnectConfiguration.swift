//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum AutoConnectConfiguration: String, CustomLocalizedStringResourceConvertible {
    case off
    case on // swiftlint:disable:this identifier_name
    case background

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .off:
            return "Off"
        case .on:
            return "On"
        case .background:
            return "In Background"
        }
    }
}
