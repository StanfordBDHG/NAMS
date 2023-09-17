//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


enum ConnectionState: Int {
    case unknown
    case connected
    case connecting
    case disconnected
    case interventionRequired // TODO think about how to present text once we visualize it!
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
