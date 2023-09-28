//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum Fit: String, Hashable, CustomLocalizedStringResourceConvertible {
    case good
    case mediocre
    case poor


    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .good:
            return "GOOD_FIT"
        case .mediocre:
            return "MEDIOCRE_FIT"
        case .poor:
            return "POOR_FIT"
        }
    }

    var style: Color {
        switch self {
        case .good:
            return .green
        case .mediocre:
            return .orange
        case .poor:
            return .red
        }
    }
}
