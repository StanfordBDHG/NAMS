//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension IXNMuseModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mu01:
            return "Muse (2014)"
        case .mu02:
            return "Muse (2016)"
        case .mu03:
            return "Muse 2"
        case .mu04:
            return "Muse S" // 2019
        case .mu05:
            return "Muse S (Gen 2)"
        @unknown default:
            return "Unknown Muse"
        }
    }
}
#endif
