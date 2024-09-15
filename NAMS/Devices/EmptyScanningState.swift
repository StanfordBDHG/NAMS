//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
@_spi(APISupport)
import SpeziBluetooth


struct EmptyScanningState: BluetoothScanningState {
    init() {}

    func merging(with other: EmptyScanningState) -> EmptyScanningState {
        EmptyScanningState()
    }

    func updateOptions(minimumRSSI: Int?, advertisementStaleInterval: TimeInterval?) -> EmptyScanningState {
        EmptyScanningState()
    }
}
