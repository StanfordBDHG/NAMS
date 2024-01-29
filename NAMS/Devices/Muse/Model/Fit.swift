//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum Fit: String, Hashable, CustomLocalizedStringResourceConvertible {
    case good
    case mediocre
    case poor


    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .good:
            .init("good", comment: "Muse headband fit")
        case .mediocre:
            .init("mediocre", comment: "Muse headband fit")
        case .poor:
            .init("poor", comment: "Muse headband fit")
        }
    }
}
