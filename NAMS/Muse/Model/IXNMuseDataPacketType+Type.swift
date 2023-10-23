//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension IXNMuseDataPacketType {
    var isEEGPacket: Bool {
        switch self {
        // non-exhaustive list of EEG packets
        case .eeg, .alphaAbsolute, .betaAbsolute, .gammaAbsolute, .deltaAbsolute, .thetaAbsolute:
            return true
        default:
            return false
        }
    }
}
#endif
