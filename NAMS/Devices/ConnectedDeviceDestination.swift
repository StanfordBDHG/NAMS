//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ConnectedDeviceDestination: View {
    private let device: ConnectedDevice

    var body: some View {
        switch device {
        case let .biopot(biopot):
            BiopotDeviceDetailsView(device: biopot) {
                Task {
                    await device.disconnect()
                }
            }
#if MUSE
        case let .muse(muse):
            MuseDeviceDetailsView(model: muse.model, state: muse.connectionState, muse.deviceInformation) {
                muse.disconnect()
            }
#endif
        case let .mock(mock):
            MuseDeviceDetailsView(model: mock.label, state: mock.connectionState, mock.deviceInformation) {
                mock.disconnect()
            }
        }
    }

    
    init(device: ConnectedDevice) {
        self.device = device
    }
}
