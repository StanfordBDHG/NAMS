//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


struct DownsampleConfiguration { // TODO: move
    let samplesToCombine: Int
    let resultingSampleRate: Double


    init(samplesToCombine: Int, resultingSampleRate: Double) {
        self.samplesToCombine = samplesToCombine
        self.resultingSampleRate = resultingSampleRate
    }

    init?(targetSampleRate: Int, sourceSampleRate: Int) {
        // target sample rate must be lower, otherwise, we don't do any downsampling
        guard targetSampleRate < sourceSampleRate else {
            return nil
        }

        let samplesToCombine = sourceSampleRate / targetSampleRate
        let resultingSampleRate: Double
        if sourceSampleRate % targetSampleRate == 0 {
            resultingSampleRate = Double(targetSampleRate)
        } else {
            resultingSampleRate = Double(sourceSampleRate) / Double(samplesToCombine)
        }

        self.init(samplesToCombine: samplesToCombine, resultingSampleRate: resultingSampleRate)
    }
}
