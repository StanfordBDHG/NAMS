//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


protocol PatientTask: Identifiable where ID == String {
    var title: LocalizedStringResource { get }
    var description: LocalizedStringResource { get }
    var completedDescription: LocalizedStringResource { get }

    var tileType: TileType { get }
    var expectedCompletionMinutes: String { get }
}


extension PatientTask {
    var completedDescription: LocalizedStringResource {
        description
    }
}
