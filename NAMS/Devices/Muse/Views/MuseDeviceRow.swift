//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


#if MUSE
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
                MuseDeviceDetailsView(model: device.model, state: device.connectionState, device.deviceInformation) {
                    device.disconnect()
                }
            }
    }


    init(device: MuseDevice) {
        self.device = device
    }
}
#endif
