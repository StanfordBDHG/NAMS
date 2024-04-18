//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


extension EEGLocation {
    // non-standard Biopot positions
    static let lme: EEGLocation = .custom("LME")
    static let mm: EEGLocation = .custom("MM") // swiftlint:disable:this identifier_name
}
