//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziDevicesUI
import SpeziViews
import SwiftUI


struct MockDeviceRow: View {
    private let device: MockDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Binding private var path: NavigationPath
    @State private var state: ViewState = .idle


    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                do {
                    try await deviceCoordinator.tapDevice(.mock(device))
                } catch {
                    state = .error(AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "Failed to connect to device."
                    ))
                }
            }
        } secondaryAction: {
            path.append(ConnectedDevice.mock(device))
        }
            .viewStateAlert(state: $state)
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
