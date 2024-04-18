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

    public var shortDescription: String {
        switch self {
        case .mu01:
            return "MUSE_14"
        case .mu02:
            return "MUSE_16"
        case .mu03:
            return "MUSE_2"
        case .mu04:
            return "MUSE_S" // 2019
        case .mu05:
            return "MUSE_S2"
        @unknown default:
            return "MUSE_?"
        }
    }
}
#endif
