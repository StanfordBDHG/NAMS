//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SwiftUI


struct MockDeviceRow: View {
    private let device: MockDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Binding private var path: NavigationPath


    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.mock(device))
            }
        } secondaryAction: {
            path.append(ConnectedDevice.mock(device))
        }
    }


    init(device: MockDevice, path: Binding<NavigationPath>) {
        self.device = device
        self._path = path
    }
}


#if DEBUG
#Preview {
    NavigationStackWithPath { path in
        List {
            MockDeviceRow(device: MockDevice(name: "Device 1"), path: path)
            MockDeviceRow(device: MockDevice(name: "Device 2", state: .connected), path: path)
        }
            .previewWith {
                DeviceCoordinator()
            }
            .navigationDestination(for: ConnectedDevice.self) { device in
                ConnectedDeviceDestination(device: device)
            }
    }
}
#endif
