//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//


@globalActor
actor EEGProcessing {
    static let shared = EEGProcessing()

    @EEGProcessing
    static func run(body: @EEGProcessing () -> Void) { // TODO: verify against MainActor.run
        body()
    }
}
