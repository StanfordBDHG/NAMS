//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


@Observable
class EEGRecordingSession {
    private(set) var measurements: [EEGFrequency: [EEGSeries]] = [:]


    func append(series: EEGSeries, for frequency: EEGFrequency) {
        measurements[frequency, default: []]
            .append(series)
    }

    func append(series: [EEGSeries], for frequency: EEGFrequency) {
        measurements[frequency, default: []]
            .append(contentsOf: series)
    }
}
