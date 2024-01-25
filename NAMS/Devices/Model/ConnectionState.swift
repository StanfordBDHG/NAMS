//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum ConnectionState {
    case unknown
    case connected
    case connecting
    case disconnected
    case interventionRequired(_ message: LocalizedStringResource)

    
    var associatedConnection: Bool {
        switch self {
        case .connected, .connecting, .interventionRequired:
            return true
        case .unknown, .disconnected:
            return false
        }
    }

    var establishedConnection: Bool {
        switch self {
        case .connected, .interventionRequired:
            return true
        case .unknown, .disconnected, .connecting:
            return false
        }
    }
}


extension ConnectionState: Equatable {}


extension ConnectionState: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .disconnected, .unknown:
            return "DISCONNECTED"
        case .connecting:
            return "CONNECTING"
        case .connected:
            return "CONNECTED"
        case .interventionRequired:
            return "INTERVENTION_REQUIRED"
        }
    }
}


extension ConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnected:
            return "disconnected"
        case .interventionRequired:
            return "interventionRequired"
        }
    }
}
