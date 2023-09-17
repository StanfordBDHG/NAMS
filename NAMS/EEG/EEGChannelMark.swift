//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct EEGChannelMark: ChartContent {
    private let time: TimeInterval
    private let reading: EEGReading

    var body: some ChartContent {
        LineMark(
            x: .value("Seconds", time),
            y: .value("Micro-Volt", reading.value)
        )
            .lineStyle(StrokeStyle(lineWidth: 2.0)) // TODO strokes?
            .foregroundStyle(.orange) // TODO color?
            .foregroundStyle(by: .value("Channel", reading.channel.rawValue)) // TODO present differently
            // .interpolationMethod(.cardinal) // TODO?=
    }


    init(time: TimeInterval, reading: EEGReading) {
        self.time = time
        self.reading = reading
    }
}


// TODO previews?
