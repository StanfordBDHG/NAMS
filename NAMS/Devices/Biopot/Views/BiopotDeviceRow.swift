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

    @State private var presentingActiveDevice: BiopotDevice?


    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.biopot(device))
            }
        } secondaryAction: {
            presentingActiveDevice = device
        }
            // TODO: this is a problem, destination modifier inside List
            .navigationDestination(item: $presentingActiveDevice) { device in
                BiopotDeviceDetailsView(device: device) {
                    Task {
                        await device.disconnect()
                    }
                }
            }
    }

    init(device: BiopotDevice) {
        self.device = device
    }
}


#if DEBUG
#Preview {
    let biopot = BiopotDevice.createMock(state: .connected)
    return NavigationStack {
        List {
            BiopotDeviceRow(device: biopot)
            BiopotDeviceRow(device: BiopotDevice.createMock(serial: "0xDDEEFFGG"))
        }
    }
        .environment(DeviceCoordinator(mock: .biopot(biopot)))
}
#endif
