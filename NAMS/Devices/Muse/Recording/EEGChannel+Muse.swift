//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension EEGChannel {
    var ixnEEG: IXNEeg {
        switch self {
        case .tp9:
            return .EEG1
        case .af7:
            return .EEG2
        case .af8:
            return .EEG3
        case .tp10:
            return .EEG4
        default:
            preconditionFailure("EEGChannel \(self) is not supported by Muse!")
        }
    }
}
#endif
