//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


/// Defines how samples are moved to the main thread
enum ProcessingType {
    /// Multiple samples are grouped together into a single UI update. The `batchRate` defines the requested update rate in Hz.
    case batched(batchRate: Int)
    /// Downsample to a given sample rate in Hz.
    case downsample(targetSampleRate: Int)
}


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

    public init?(from processing: ProcessingType, sourceSampleRate: Int) {
        let action: BatchingAction
        let targetSampleRate: Int

        switch processing {
        case let .batched(batchRate):
            action = .none
            targetSampleRate = batchRate
        case let .downsample(targetSampleRate0):
            action = .downsample
            targetSampleRate = targetSampleRate0
        }

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

        self.init(samplesToCombine: samplesToCombine, batchingFrequency: resultingSampleRate, action: action)
    }
}
