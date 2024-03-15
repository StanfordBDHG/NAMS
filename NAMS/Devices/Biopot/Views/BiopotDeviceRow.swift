//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SpeziBluetooth
import SwiftUI


struct BiopotDeviceRow: View {
    private let device: BiopotDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Binding private var path: NavigationPath


    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.biopot(device))
            }
        } secondaryAction: {
            path.append(ConnectedDevice.biopot(device))
        }
    }

    init(device: BiopotDevice, path: Binding<NavigationPath>) {
        self.device = device
        self._path = path
    }
}


#if DEBUG
#Preview {
    let biopot = BiopotDevice.createMock(state: .connected)
    return NavigationStackWithPath { path in
        List {
            BiopotDeviceRow(device: biopot, path: path)
            BiopotDeviceRow(device: BiopotDevice.createMock(serial: "0xDDEEFFGG"), path: path)
        }
            .navigationDestination(for: ConnectedDevice.self) { device in
                ConnectedDeviceDestination(device: device)
            }
    }
        .environment(DeviceCoordinator(mock: .biopot(biopot)))
}
#endif
