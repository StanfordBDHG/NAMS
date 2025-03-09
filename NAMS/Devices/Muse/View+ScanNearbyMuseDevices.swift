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


#if MUSE
extension View {
    func scanNearbyDevices(
        enabled: Bool = true, // swiftlint:disable:this function_default_parameter_at_end
        with museManager: MuseDeviceManager
    ) -> some View {
        scanNearbyDevices(enabled: enabled, scanner: museManager, state: EmptyScanningState())
    }
}
#endif
