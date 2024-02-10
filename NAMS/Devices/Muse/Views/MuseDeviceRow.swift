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
private struct MuseDeviceDestination: View {
    private let device: MuseDevice

    var body: some View {
        MuseDeviceDetailsView(model: device.model, state: device.connectionState, device.deviceInformation) {
            device.disconnect()
        }
    }

    init(_ device: MuseDevice) {
        self.device = device
    }
}

struct MuseDeviceRow: View {
    private let device: MuseDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @State private var presentingActiveDevice: MuseDevice?

    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.muse(device))
            }
        } secondaryAction: {
            presentingActiveDevice = device
        }
            .navigationDestination(item: $presentingActiveDevice) { device in
                MuseDeviceDestination(device)
            }
    }


    init(device: MuseDevice) {
        self.device = device
    }
}
#endif
