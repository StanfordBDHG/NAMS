//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MockDeviceRow: View {
    private let device: MockDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @State private var presentingActiveDevice: MockDevice?


    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                await deviceCoordinator.tapDevice(.mock(device))
            }
        } secondaryAction: {
            if device.state == .connected {
                presentingActiveDevice = device
            }
        }
            .navigationDestination(item: $presentingActiveDevice) { device in
                if let info = device.deviceInformation {
                    MuseDeviceDetailsView(model: device.label, state: device.connectionState, info) {
                        device.disconnect()
                        // TODO: this needs a better approach
                        deviceCoordinator.hintDisconnect()
                    }
                }
            }
    }


    init(device: MockDevice) {
        self.device = device
    }
}


#if DEBUG
// TODO: preview
#endif
