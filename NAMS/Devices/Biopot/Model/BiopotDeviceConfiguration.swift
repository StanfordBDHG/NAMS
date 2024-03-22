//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

private struct BiopotElectrodeLocationsContainer {
    let locations: BiopotElectrodeLocations

    init(locations: BiopotElectrodeLocations) {
        self.locations = locations
    }
}


@Observable
class BiopotDeviceConfiguration {
    @AppStorage("nams.biopot.electrode.selection")
    @ObservationIgnored private var _electrodeSelection: PredefinedElectrodeLocation = .cap

    @AppStorage("nams.biopot.electrode.selection")
    @ObservationIgnored private var _customElectrodesLocations: BiopotElectrodeLocationsContainer = .init(locations: .cap)


    var electrodeSelection: PredefinedElectrodeLocation {
        get {
            access(keyPath: \.electrodeSelection)
            return _electrodeSelection
        }
        set {
            withMutation(keyPath: \.electrodeSelection) {
                _electrodeSelection = newValue
            }
        }
    }

    var customElectrodesLocations: BiopotElectrodeLocations {
        get {
            access(keyPath: \.customElectrodesLocations)

            return _customElectrodesLocations.locations
        }
        set {
            withMutation(keyPath: \.customElectrodesLocations) {
                _customElectrodesLocations = .init(locations: newValue)
            }
        }
    }

    var electrodeLocations: BiopotElectrodeLocations {
        switch electrodeSelection {
        case .cap:
            .cap
        case .paper:
            .paper
        case .custom:
            customElectrodesLocations
        }
    }
}


extension BiopotElectrodeLocationsContainer: RawRepresentable {
    var rawValue: String {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(locations)

            guard let string = String(data: data, encoding: .utf8) else {
                preconditionFailure("Failed to encode data to utf8 string.")
            }

            return string
        } catch {
            preconditionFailure("Failed to encode electrode locations \(error)")
        }
    }

    init?(rawValue: String) {
        let decoder = JSONDecoder()
        do {
            guard let data = rawValue.data(using: .utf8) else {
                return nil
            }
            self = .init(locations: try decoder.decode(BiopotElectrodeLocations.self, from: data))
        } catch {
            print("Decode failed: \(error)")

            return nil // we just fallback to the default
        }
    }
}
