//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


/// A single sample combining the value of all channels.
struct CombinedEEGSample {
    /// The list of samples for all channels.
    ///
    /// Channels are referred by the index. The order must be the same as the provided `Signal` description.
    let channels: [BDFSample]


    init(channels: [BDFSample]) {
        self.channels = channels
    }
}
