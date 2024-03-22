//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


struct BufferedChannel<S: Sample> {
    private(set) var samples: [S]

    init(samples: [S] = []) {
        self.samples = samples
    }

    mutating func append(_ sample: S) {
        samples.append(sample)
    }


    func hasBuffered(count minimumAmount: Int) -> Bool {
        samples.count >= minimumAmount
    }

    mutating func pop(count: Int) -> Channel<S> {
        let channel = Channel(samples: Array(samples.prefix(count)))
        samples.removeFirst(count)
        return channel
    }
}


extension BufferedChannel: Hashable, Sendable {}
