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
            EEGChannelMark(time: max(0.0, series.timestamp.timeIntervalSince1970 - baseTime!), reading: series.reading(for: channel))
            // TODO channel opacity of invalid data!
        }
            .chartXScale(domain: lowerScale...upperScale)
            // TODO .chartYScale(domain: -500.0...1250.0)
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


// TODO previews
