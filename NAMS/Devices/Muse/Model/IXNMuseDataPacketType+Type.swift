//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
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
