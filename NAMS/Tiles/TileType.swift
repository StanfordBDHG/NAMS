//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum TileType: CustomLocalizedStringResourceConvertible {
    case questionnaire

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .questionnaire:
            return .init("Questionnaire", comment: "Tile Type")
        }
    }
}
