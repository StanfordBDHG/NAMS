//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct EEGSeries: Identifiable {
    var id: Date {
        timestamp
    }

    let timestamp: Date
    private let readingsDictionary: [EEGChannel: EEGReading]

    var channels: [EEGChannel] {
        Array(readingsDictionary.keys)
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
