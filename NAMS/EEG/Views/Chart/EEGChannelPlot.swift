//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct EEGChannelPlot: ChartContent {
    private let signal: SignalLabel
    private let samples: [TimedSample<BDFSample>]

    var body: some ChartContent {
        LinePlot(
            samples,
            x: .value("Seconds", \.time),
            y: .value("Micro-Volt", \.value)
        )
            .lineStyle(StrokeStyle(lineWidth: 2.0))
            .foregroundStyle(by: .value("Channel", signal.location ?? signal.type.rawValue))
    }

    init(signal: SignalLabel, samples: [TimedSample<BDFSample>]) {
        self.signal = signal
        self.samples = samples
    }
}


#if DEBUG
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af7), sampleTime: 5, recordingOffset: 10),
        displayedInterval: 5.0,
        valueInterval: 50
    )
}
#endif
