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
            .lineStyle(StrokeStyle(lineWidth: 2.0))
            .foregroundStyle(by: .value("Channel", reading.channel.rawValue))
    }


    init(time: TimeInterval, reading: EEGReading) {
        self.time = time
        self.reading = reading
    }
}


#if DEBUG
#Preview {
    let randomSamples = EEGMeasurementGenerator(sampleRate: 60)
    let generated = randomSamples.generateRecording(sampleTime: 5, recordingOffset: 10)
    return EEGChart(measurements: generated.data.suffix(from: 0), for: .af7, baseTime: generated.baseTime)
}
#endif
