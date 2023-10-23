//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct EEGChart: View {
    private let measurements: ArraySlice<EEGSeries>
    private let channel: EEGChannel
    /// The base time interval since 1970.
    private let baseTime: TimeInterval?

    private var lowerScale: TimeInterval {
        if let first = measurements.first,
           let baseTime {
            return max(0, first.timestamp.timeIntervalSince1970 - baseTime)
        }
        return 0
    }

    private var upperScale: TimeInterval {
        if let last = measurements.last,
           let baseTime {
            return max(1, last.timestamp.timeIntervalSince1970 - baseTime)
        }
        return 1
    }

    var body: some View {
        Chart(measurements) { series in
            // base time exists if there is at least one measurement
            let baseTime = baseTime ?? 0

            EEGChannelMark(time: max(0.0, series.timestamp.timeIntervalSince1970 - baseTime), reading: series.reading(for: channel))
        }
            .chartXScale(domain: lowerScale...upperScale)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 12)) { value in
                    if let doubleValue = value.as(Double.self),
                       let intValue = value.as(Int.self) {
                        if doubleValue - Double(intValue) == 0 {
                            AxisTick(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                            AxisValueLabel {
                                Text("\(intValue)s")
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


    init(measurements: ArraySlice<EEGSeries>, for channel: EEGChannel, baseTime: TimeInterval?) {
        self.measurements = measurements
        self.channel = channel
        self.baseTime = baseTime
    }
}


#if DEBUG
struct EEGChart_Previews: PreviewProvider {
    static let randomSamples = EEGMeasurementGenerator(sampleRate: 60)

    static var previews: some View {
        let generated = randomSamples.generateRecording(sampleTime: 5, recordingOffset: 10)
        EEGChart(measurements: generated.data.suffix(from: 0), for: .af7, baseTime: generated.baseTime)
        EEGChart(measurements: generated.data.suffix(from: 0), for: .af8, baseTime: generated.baseTime)
    }
}
#endif
