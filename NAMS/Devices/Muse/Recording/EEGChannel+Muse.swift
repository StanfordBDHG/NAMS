//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


#if MUSE
extension EEGLocation {
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
