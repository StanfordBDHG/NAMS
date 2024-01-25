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
    var measurements: [EEGFrequency: [EEGSeries]] = [:]
}
