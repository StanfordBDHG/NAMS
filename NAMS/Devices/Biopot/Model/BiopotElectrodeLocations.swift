//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


struct BiopotElectrodeLocations {
    var channel1: EEGLocation
    var channel2: EEGLocation
    var channel3: EEGLocation
    var channel4: EEGLocation
    var channel5: EEGLocation
    var channel6: EEGLocation
    var channel7: EEGLocation
    var channel8: EEGLocation


    fileprivate init(
        _ channel1: EEGLocation,
        _ channel2: EEGLocation,
        _ channel3: EEGLocation,
        _ channel4: EEGLocation,
        _ channel5: EEGLocation,
        _ channel6: EEGLocation,
        _ channel7: EEGLocation,
        _ channel8: EEGLocation
    ) {
        self.channel1 = channel1
        self.channel2 = channel2
        self.channel3 = channel3
        self.channel4 = channel4
        self.channel5 = channel5
        self.channel6 = channel6
        self.channel7 = channel7
        self.channel8 = channel8
    }


    func toList() -> [EEGLocation] {
        [channel1, channel2, channel3, channel4, channel5, channel6, channel7, channel8]
    }
}


extension BiopotElectrodeLocations {
    static let cap = BiopotElectrodeLocations(.c4, .c3, .af7, .tp8, .af8, .tp7, .cp2, .cp1)

    static let paper = BiopotElectrodeLocations(.lme, .tp10, .af8, .fp2, .fpz, .fp1, .af7, .mm)

    static func custom( // swiftlint:disable:this function_parameter_count
        _ channel1: EEGLocation,
        _ channel2: EEGLocation,
        _ channel3: EEGLocation,
        _ channel4: EEGLocation,
        _ channel5: EEGLocation,
        _ channel6: EEGLocation,
        _ channel7: EEGLocation,
        _ channel8: EEGLocation
    ) -> BiopotElectrodeLocations {
        .init(channel1, channel2, channel3, channel4, channel5, channel6, channel7, channel8)
    }
}


extension BiopotElectrodeLocations: Codable, Hashable, Sendable {}


extension BiopotElectrodeLocations: Collection {
    public typealias Index = [EEGLocation].Index

    public var startIndex: Index {
        0
    }

    public var endIndex: Index {
        8
    }


    public func index(after index: Index) -> Index {
        index + 1
    }


    public subscript(position: Index) -> EEGLocation {
        toList()[position]
    }
}
