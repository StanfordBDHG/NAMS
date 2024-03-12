//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SwiftUI


private struct MockDeviceDestination: View {
    private let device: MockDevice

    var body: some View {
        MuseDeviceDetailsView(model: device.label, state: device.connectionState, device.deviceInformation) {
            device.disconnect()
        }
    }

    init(_ device: MockDevice) {
        self.device = device
    }
}


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
            // TODO: this is a problem, destination modifier inside List
            .navigationDestination(item: $presentingActiveDevice) { device in
                MockDeviceDestination(device)
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
