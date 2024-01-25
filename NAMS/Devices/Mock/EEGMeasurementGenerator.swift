//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


class EEGMeasurementGenerator {
    private let sampleRate: Int
    private let baseValue: Double

    private var sampleDuration: TimeInterval {
        1.0 / Double(sampleRate)
    }


    // properties for stateful generation.
    private var values: [EEGChannel: Double]
    private var currentTime: TimeInterval


    /// Generate a new set of random EEG measurements.
    ///
    /// This is cannot be used to simulate real-looking EEG measurement! However, if you are interested,
    /// there is considerable research on how to generate such data
    /// (e.g., see https://web.archive.org/web/20221128022413/https://data.mrc.ox.ac.uk/data-set/simulated-eeg-data-generator).
    ///
    /// - Parameters:
    ///   - sampleRate: The sample rate in Hz. Must be greater than zero.
    ///   - baseValue: The base value for value generation.
    init(
        sampleRate: Int,
        baseValue: Double = 2.0
    ) {
        precondition(sampleRate > 0, "Sample rate must be positive and non-zero.")

        self.sampleRate = sampleRate
        self.baseValue = baseValue

        self.values = [:]
        self.currentTime = Date.now.timeIntervalSince1970
    }


    private func generate(values: inout [EEGChannel: Double], time: inout Double) -> EEGSeries {
        time += sampleDuration

        let readings = [EEGChannel.tp9, .af7, .af8, .tp10].map { channel in
            values[channel, default: baseValue] += Double.random(in: -3.35...3.5)
            return EEGReading(channel: channel, value: values[channel, default: baseValue])
        }

        return EEGSeries(timestamp: Date(timeIntervalSince1970: time), readings: readings)
    }

    func next() -> EEGSeries {
        generate(values: &values, time: &currentTime)
    }

    /// Generate a set of ``EEGSeries`` in a stateless manner, useful for Previews.
    /// - Parameters:
    ///   - sampleTime: The total time of the eeg recording in seconds.
    ///   - recordingOffset: Defines the time difference between the recording start and the first sample.
    ///     E.g., a recording might have started 60 seconds ago, but the app only shows the last ten seconds (sliding window).
    ///     In this case you would set `recordingOffset` to 50.
    /// - Returns: The generate measurements.
    func generateRecording(sampleTime: TimeInterval, recordingOffset: TimeInterval = 0) -> (baseTime: TimeInterval, data: [EEGSeries]) {
        let now = Date.now.timeIntervalSince1970 // get now once!

        let firstSampleSince1970: TimeInterval = now - sampleTime
        let baseTimeSince1970 = firstSampleSince1970 - recordingOffset
        let samples = Int(sampleTime * Double(sampleRate))

        var result: [EEGSeries] = []
        var values: [EEGChannel: Double] = [:]
        var currentTime = firstSampleSince1970

        for _ in 0..<samples {
            let series = generate(values: &values, time: &currentTime)
            result.append(series)
        }

        return (baseTimeSince1970, result)
    }
}
