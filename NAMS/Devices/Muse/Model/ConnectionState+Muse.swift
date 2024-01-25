//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension ConnectionState {
    init(from state: IXNConnectionState) {
        switch state {
        case .unknown:
            self = .unknown
        case .connected:
            self = .connected
        case .connecting:
            self = .connecting
        case .disconnected:
            self = .disconnected
        case .needsUpdate:
            self = .interventionRequired("INTERVENTION_MUSE_FIRMWARE")
        case .needsLicense:
            self = .interventionRequired("INTERVENTION_MUSE_LICENSE")
        @unknown default:
            self = .unknown
        }
    }
}
#endif
