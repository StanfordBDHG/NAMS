//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


struct EEGReading {
    let location: EEGLocation
    /// Value in micro volts
    let value: Double


    init(location: EEGLocation, value: Double) {
        self.location = location
        self.value = value
    }
}
