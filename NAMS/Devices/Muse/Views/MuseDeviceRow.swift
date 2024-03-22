//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SwiftUI


#if MUSE
struct MuseDeviceRow: View {
    private let device: MuseDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Binding private var path: NavigationPath

    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.muse(device))
            }
        } secondaryAction: {
            path.append(ConnectedDevice.muse(device))
        }
    }


    init(device: MuseDevice, path: Binding<NavigationPath>) {
        self.device = device
        self._path = path
    }
}
#endif
