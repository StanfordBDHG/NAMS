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
            presentingActiveDevice = device
        }
            .navigationDestination(item: $presentingActiveDevice) { device in
                MuseDeviceDetailsView(model: device.label, state: device.connectionState, device.deviceInformation) {
                    device.disconnect()
                }
            }
    }


    init(device: MockDevice) {
        self.device = device
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        List {
            MockDeviceRow(device: MockDevice(name: "Device 1"))
            MockDeviceRow(device: MockDevice(name: "Device 2", state: .connected))
        }
        .previewWith {
            DeviceCoordinator()
        }
    }
}
#endif
