//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


struct VisualizedSignal {
    let label: SignalLabel
    let sampleRate: Int
    let sampleOffset: Int

    var samples: [BDFSample]

    var timedSamples: [TimedSample<BDFSample>] {
        samples.enumerated().reduce(into: []) { result, enumerated in
            result.append(TimedSample(time: time(forSample: enumerated.offset), sample: enumerated.element))
        }
    }


    var lowerBound: TimeInterval {
        time(forSample: 0)
    }

    init(label: SignalLabel, sampleRate: Int, sampleOffset: Int = 0, samples: [BDFSample]) {
        // swiftlint:disable:previous function_default_parameter_at_end
        self.label = label
        self.sampleRate = sampleRate
        self.sampleOffset = sampleOffset
        self.samples = samples
    }

    init(copy signal: VisualizedSignal, suffix: TimeInterval) {
        let suffixCount = Int(suffix * Double(signal.sampleRate))

        self.label = signal.label
        self.sampleRate = signal.sampleRate
        self.sampleOffset = signal.sampleOffset + max(0, signal.samples.count - suffixCount)

        self.samples = signal.samples.suffix(suffixCount)
    }


    private func time(forSample offset: Int) -> TimeInterval {
        // we calculate time with SAMPLE_COUNT/SAMPLE_RATE
        Double(sampleOffset + offset) / Double(sampleRate)
    }
}
