//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
@_spi(APISupport)
import SpeziBluetooth


extension View {
    func scanNearbyDevices(
        enabled: Bool = true,  // swiftlint:disable:this function_default_parameter_at_end
        with mockManager: MockDeviceManager
    ) -> some View {
        scanNearbyDevices(enabled: enabled, scanner: mockManager, state: EmptyScanningState())
    }
}
