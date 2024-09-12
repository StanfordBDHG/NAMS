//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziDevicesUI
import SpeziViews
import SwiftUI


#if MUSE
struct MuseDeviceRow: View {
    private let device: MuseDevice

    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    @Binding private var path: NavigationPath
    @State private var state: ViewState = .idle

    var body: some View {
        NearbyDeviceRow(peripheral: device) {
            Task {
                do {
                    try await deviceCoordinator.tapDevice(.muse(device))
                } catch {
                    state = .error(AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "Failed to connect to device."
                    ))
                }
            }
        } secondaryAction: {
            path.append(ConnectedDevice.muse(device))
        }
            .viewStateAlert(state: $state)
    }


    init(device: MuseDevice, path: Binding<NavigationPath>) {
        self.device = device
        self._path = path
    }
}
#endif
