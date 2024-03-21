//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


@Observable
class VisualizedSignal {
    /// The label of the signal.
    let label: SignalLabel
    /// The sample rate of the source signal.
    let sourceSampleRate: Int
    /// The offset at which `samples` are stored.
    let sampleOffset: Int
    /// Optional batching of samples for improved ui performance.
    let batching: BatchingConfiguration?

    @MainActor var samples: [BDFSample]

    var effectiveSampleRate: Double {
        if let batching, case .downsample = batching.action {
            batching.batchingFrequency // batching frequency corresponds to the resulting sample frequency
        } else {
            Double(sourceSampleRate)
        }
    }

    @MainActor var timedSamples: [TimedSample<BDFSample>] {
        samples.enumerated().reduce(into: []) { result, enumerated in
            result.append(TimedSample(time: time(forSample: enumerated.offset), sample: enumerated.element))
        }
    }


    var lowerBound: TimeInterval {
        time(forSample: 0)
    }

    
    init(label: SignalLabel, sourceSampleRate: Int, batching: BatchingConfiguration?, sampleOffset: Int = 0, samples: [BDFSample] = []) {
        self.label = label
        self.sourceSampleRate = sourceSampleRate
        self.batching = batching
        self.sampleOffset = sampleOffset
        self._samples = samples
    }

    @MainActor
    init(copy signal: VisualizedSignal, suffix: TimeInterval) {
        let suffixCount = Int(suffix * signal.effectiveSampleRate)

        self.label = signal.label
        self.sourceSampleRate = signal.sourceSampleRate
        self.batching = signal.batching
        self.sampleOffset = signal.sampleOffset + max(0, signal.samples.count - suffixCount)

        self.samples = signal.samples.suffix(suffixCount)
    }


    private func time(forSample offset: Int) -> TimeInterval {
        // we calculate time with SAMPLE_COUNT/SAMPLE_RATE
        Double(sampleOffset + offset) / effectiveSampleRate
    }
}


extension VisualizedSignal: CustomStringConvertible {
    var description: String {
        "VisualizedSignal(label: \(label), sourceSampleRate: \(sourceSampleRate), sampleOffset: \(sampleOffset), batching: \(String(describing: batching))"
    }
}
