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

    var body: some View {
        Chart(signal.timedSamples, id: \.time) { sample in
            EEGChannelMark(signal: signal.label, time: sample.time, value: sample.value)
        }
        // TODO: fixed YScale!! (configurable?)
        .chartXScale(domain: signal.lowerBound...(signal.lowerBound + displayedInterval))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 12)) { value in
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
            AxisMarks(values: .automatic(desiredCount: 14)) { _ in
                AxisGridLine(stroke: .init(lineWidth: 1))
                    .foregroundStyle(.gray.opacity(0.25))
            }
        }
        .chartPlotStyle {
            $0.border(Color.gray)
        }
        .frame(height: 200)
    }


    init(signal: VisualizedSignal, displayedInterval: TimeInterval) {
        self.signal = signal
        self.displayedInterval = displayedInterval
    }
}


#if DEBUG
#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af7), sampleTime: 5.2, recordingOffset: 10),
        displayedInterval: 6
    )
}

#Preview {
    EEGChart(
        signal: MockMeasurementGenerator(sampleRate: 60).generateSignal(label: .eeg(location: .af8), sampleTime: 5.4, recordingOffset: 10),
        displayedInterval: 6
    )
}
#endif
