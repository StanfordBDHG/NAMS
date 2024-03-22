//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

enum BatchingAction {
    case none
    case downsample
}


/// Collect samples into batches for reduced ui updates.
///
/// For the live visualization, samples are collected into batches before they are sent to the main actor for display.
struct BatchingConfiguration {
    /// The amount of samples to combine into a
    let samplesToCombine: Int
    let batchingFrequency: Double
    let action: BatchingAction


    private init(samplesToCombine: Int, batchingFrequency: Double, action: BatchingAction) {
        self.samplesToCombine = samplesToCombine
        self.batchingFrequency = batchingFrequency
        self.action = action
    }
}


extension BatchingConfiguration {
    @inlinable
    static func batch(samplesToCombine: Int, batchingFrequency: Double) -> BatchingConfiguration {
        BatchingConfiguration(samplesToCombine: samplesToCombine, batchingFrequency: batchingFrequency, action: .none)
    }

    static func downsample(targetSampleRate: Int, sourceSampleRate: Int) -> BatchingConfiguration? {
        // target sample rate must be lower, otherwise, we don't do any downsampling
        guard targetSampleRate < sourceSampleRate else {
            return nil
        }

        let samplesToCombine = sourceSampleRate / targetSampleRate
        let resultingSampleRate: Double
        if sourceSampleRate.isMultiple(of: targetSampleRate) {
            resultingSampleRate = Double(targetSampleRate)
        } else {
            // otherwise, we want to have the `samplesToCombine` to be a whole number and adjust the `resultingSampleRate` to be double
            resultingSampleRate = Double(sourceSampleRate) / Double(samplesToCombine)
        }

        return BatchingConfiguration(samplesToCombine: samplesToCombine, batchingFrequency: resultingSampleRate, action: .downsample)
    }
}
