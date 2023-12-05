//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension EEGChannel {
    init?(biopotNum value: Int) {
        switch value {
        case 1:
            self = .lme
        case 2:
            self = .tp10
        case 3:
            self = .af8
        case 4:
            self = .fp2
        case 5:
            self = .fpz
        case 6:
            self = .fp1
        case 7:
            self = .af7
        case 8:
            self = .mm
        default:
            return nil
        }
    }
}
