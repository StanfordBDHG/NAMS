//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


struct TimedSample<S: Sample> {
    let time: TimeInterval
    private let sample: S

    var value: S.Value {
        sample.value
    }

    init(time: TimeInterval, sample: S) {
        self.time = time
        self.sample = sample
    }
}


extension TimedSample: Hashable {
    static func == (lhs: TimedSample, rhs: TimedSample) -> Bool {
        lhs.sample == rhs.sample
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(sample)
    }
}
