//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import EDFFormat
import SwiftUI


struct EEGChannelMark: ChartContent {
    private let signal: SignalLabel
    private let time: TimeInterval
    private let value: BDFSample.Value

    var body: some ChartContent {
        LineMark(
            x: .value("Seconds", time),
            y: .value("Micro-Volt", value)
        )
            .lineStyle(StrokeStyle(lineWidth: 2.0))
            .foregroundStyle(by: .value("Channel", signal.location ?? signal.type.rawValue))
    }


    init(signal: SignalLabel, time: TimeInterval, value: BDFSample.Value) {
        self.signal = signal
        self.time = time
        self.value = value
    }
}


#if DEBUG
#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af7), sampleTime: 5, recordingOffset: 10),
        displayedInterval: 5.0,
        valueInterval: 50
    )
}
#endif
