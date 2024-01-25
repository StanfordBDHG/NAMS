//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension IXNMusePreset: CustomStringConvertible {
    public var description: String {
        switch self {
        case .preset10:
             return "preset10"
        case .preset12:
            return "preset12"
        case .preset14:
            return "preset14"
        case .preset20:
            return "preset20"
        case .preset21:
            return "preset21"
        case .preset22:
            return "preset22"
        case .preset23:
            return "preset23"
        case .preset31:
            return "preset31"
        case .preset32:
            return "preset32"
        case .preset50:
            return "preset50"
        case .preset51:
            return "preset51"
        case .preset52:
            return "preset52"
        case .preset53:
            return "preset53"
        case .preset60:
            return "preset60"
        case .preset61:
            return "preset61"
        case .preset63:
            return "preset63"
        case .presetAb:
            return "presetAb"
        case .presetAd:
            return "presetAd"
        @unknown default:
            return "UNKNOWN"
        }
    }
}
#endif
