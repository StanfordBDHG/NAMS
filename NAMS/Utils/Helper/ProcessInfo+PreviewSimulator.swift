//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ProcessInfo {
    var isPreviewSimulator: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
