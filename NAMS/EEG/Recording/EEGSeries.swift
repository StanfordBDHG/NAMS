//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct EEGSeries: Identifiable {
    var id: Date {
        timestamp
    }

    private let readingsDictionary: [EEGChannel: EEGReading]

    let timestamp: Date
    var readings: Dictionary<EEGChannel, EEGReading>.Values {
        readingsDictionary.values
    }


    init(timestamp: Date, readings: [EEGReading]) {
        self.timestamp = timestamp
        self.readingsDictionary = readings.reduce(into: [:]) { result, reading in
            result[reading.channel] = reading
        }
    }


    func reading(for channel: EEGChannel) -> EEGReading {
        guard let reading = readingsDictionary[channel] else {
            preconditionFailure("Tried to access channel \(channel) which wasn't present")
        }
        return reading
    }
}
