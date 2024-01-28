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
            // TODO: we assume I button only shows if this is true!
            if device.state == .connected {
                presentingActiveDevice = device
            }
        }
            .navigationDestination(item: $presentingActiveDevice) { device in
                // TODO: should be always true??: Maybe just forward the optional (handles device disconnecting in the meantime!)
                if let info = device.deviceInformation {
                    MuseDeviceDetailsView(model: device.model, state: device.connectionState, info) {
                        device.disconnect()
                        // TODO: reconsider this archotecture to catch external disconnects
                        deviceCoordinator.hintDisconnect()
                    }
                }
            }
    }


    init(device: MuseDevice) { // TODO: we could make this generic bluetooth peripheral?
        self.device = device
    }
}
#endif


/*
// TODO: replace within MockDeviceRow!
#if DEBUG
#Preview {
    NavigationStack {
        List {
            // TODO : EEGDeviceRow(device: MockEEGDevice(name: "Nearby Device", model: "Mock"))
        }
            .environment(EEGViewModel(deviceManager: MockDeviceManager()))
    }
}

#Preview {
    let device = MockDevice(name: "Device 1", model: "Mock", state: .connecting)
    return NavigationStack {
        List {
            // TODO : EEGDeviceRow(device: device)
        }
    }
        .environment(EEGViewModel(mock: device))
}

#Preview {
    let device = MockDevice(name: "Device 2", model: "Mock", state: .connected)
    return NavigationStack {
        List {
            // TODO : EEGDeviceRow(device: device)
        }
            .environment(EEGViewModel(mock: device))
    }
}

#Preview {
    let device = MockDevice(name: "Device 3", model: "Mock", state: .interventionRequired("Firmware update required."))
    return NavigationStack {
        List {
            // TODO : EEGDeviceRow(device: device)
        }
    }
        .environment(EEGViewModel(mock: device))
}
#endif
*/
