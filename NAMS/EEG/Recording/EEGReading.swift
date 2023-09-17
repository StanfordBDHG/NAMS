//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
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
