//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum TileType: CustomLocalizedStringResourceConvertible {
    case questionnaire
    case recording

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .questionnaire:
            return .init("Questionnaire", comment: "Tile Type")
        case .recording:
            return .init("Recording", comment: "Tile Type")
        }
    }
}
