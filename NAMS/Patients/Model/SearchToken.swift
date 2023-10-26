//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum SearchToken: String, Identifiable, Hashable, CaseIterable {
    case patientId
    case name

    var id: String {
        rawValue
    }

    @ViewBuilder var tokenLabel: some View {
        switch self {
        case .patientId:
            Label("Patient Id", systemImage: "grid.circle.fill")
        case .name:
            Label("Name", systemImage: "person.text.rectangle")
        }
    }
}
