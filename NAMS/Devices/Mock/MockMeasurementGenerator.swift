//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


class MockMeasurementGenerator {
    static let generatedLocations: [EEGLocation] = [.tp9, .af7, .af8, .tp10]

    private let sampleRate: Int
    private let baseValue: Int32


    // properties for stateful generation.
    private var values: [EEGLocation: Int32]
    private lazy var startDate: Date = .now
    private var generatedSamples = 0


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
        baseValue: Int32 = 20
    ) {
        precondition(sampleRate > 0, "Sample rate must be positive and non-zero.")

        self.sampleRate = sampleRate
        self.baseValue = baseValue

        self.values = [:]
    }

    private func generateSingle(values: inout [EEGLocation: Int32]) -> CombinedEEGSample {
        let samples = Self.generatedLocations.map { location in
            values[location, default: baseValue] += Int32.random(in: -3...3)
            return BDFSample(values[location, default: baseValue])
        }

        return CombinedEEGSample(channels: samples)
    }


    func next() -> [CombinedEEGSample] {
        let startDate = startDate
        let now: Date = .now

        // the time we are already generating.
        let generationTime = max(0, now.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        // the amount of samples we should have generated in that time.
        let expectedSamples = Int(generationTime * Double(sampleRate))

        let missingSamples = max(0, expectedSamples - generatedSamples)

        var result: [CombinedEEGSample] = []

        for _ in 0..<missingSamples {
            result.append(generateSingle(values: &values))
        }

        self.generatedSamples += missingSamples

        return result
    }

    /// Generate a eeg signal in a stateless manner, useful for Previews.
    /// - Parameters:
    ///   - sampleTime: The total time of the eeg recording in seconds.
    ///   - recordingOffset: Defines the time difference between the recording start and the first sample.
    ///     E.g., a recording might have started 60 seconds ago, but the app only shows the last ten seconds (sliding window).
    ///     In this case you would set `recordingOffset` to 50.
    /// - Returns: The generate measurements.
    func generateSignal(label: SignalLabel, sampleTime: TimeInterval, recordingOffset: TimeInterval = 0) -> VisualizedSignal {
        let samples = Int(sampleTime * Double(sampleRate))
        let sampleOffset = Int(recordingOffset * Double(sampleRate))

        var result: [BDFSample] = []
        var values: [EEGLocation: Int32] = [:]

        for _ in 0..<samples {
            let sample = generateSingle(values: &values)

            guard let first = sample.channels.first else {
                preconditionFailure("\(#function) failed to generate first channel!")
            }
            result.append(first)
        }

        return VisualizedSignal(label: label, sourceSampleRate: self.sampleRate, downsampling: nil, sampleOffset: sampleOffset, samples: result)
    }
}
