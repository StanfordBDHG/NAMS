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


struct EEGChart: View {
    private let signal: VisualizedSignal
    private let displayedInterval: TimeInterval
    private let valueInterval: Int

    var body: some View {
        Chart(signal.timedSamples, id: \.time) { sample in
            EEGChannelMark(signal: signal.label, time: sample.time, value: sample.value)
        }
            .clipped() // TODO: does that work?
            .chartXScale(domain: signal.lowerBound...(signal.lowerBound + displayedInterval))
            .chartYScale(domain: -valueInterval...valueInterval)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) { value in
                    if let doubleValue = value.as(Double.self),
                       let intValue = value.as(Int.self) {
                        if doubleValue - Double(intValue) == 0 {
                            AxisTick(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                            AxisValueLabel {
                                Text(verbatim: "\(intValue)s")
                            }
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                        } else {
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray.opacity(0.25))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 10)) { _ in
                    AxisGridLine(stroke: .init(lineWidth: 1))
                        .foregroundStyle(.gray.opacity(0.25))
                }
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    if let int = value.as(Int.self) {
                        AxisGridLine(stroke: .init(lineWidth: 1))
                        AxisValueLabel {
                            Text(verbatim: "\(int)uV")
                        }
                    }
                }
            }
            .chartPlotStyle { content in
                content
                    .border(Color.gray)
                    .frame(maxHeight: 150)
            }
    }


    init(signal: VisualizedSignal, displayedInterval: TimeInterval, valueInterval: Int) {
        self.signal = signal
        self.displayedInterval = displayedInterval
        self.valueInterval = valueInterval
    }
}


#if DEBUG
#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af7), sampleTime: 5.2, recordingOffset: 10),
        displayedInterval: 6,
        valueInterval: 150
    )
}

#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af8), sampleTime: 5.4, recordingOffset: 10),
        displayedInterval: 6,
        valueInterval: 50
    )
}
#endif
