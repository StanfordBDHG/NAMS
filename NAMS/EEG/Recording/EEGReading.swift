//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct EEGReading {
    let channel: EEGChannel
    /// Value in micro volts
    let value: Double


    init(channel: EEGChannel, value: Double) {
        self.channel = channel
        self.value = value
    }
}
