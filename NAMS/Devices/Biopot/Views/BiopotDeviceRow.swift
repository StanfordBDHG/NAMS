//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SwiftUI


struct BiopotDeviceRow: View {
    private let device: BiopotDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @State private var presentingActiveDevice: BiopotDevice?


    var body: some View {
        // TODO: how to UI test the biopot?
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.biopot(device))
            }
        } secondaryAction: {
            presentingActiveDevice = device
        }
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


// TODO: preview
