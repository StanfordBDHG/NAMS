//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EEGDeviceRow: View {
    private let device: EEGDevice
    private let eegModel: EEGViewModel

    var connectedDevice: ConnectedDevice? {
        if let activeDevice = eegModel.activeDevice,
           activeDevice.device.macAddress == device.macAddress {
            return activeDevice
        }
        return nil
    }

    @State private var presentingActiveDevice: ConnectedDevice?

    var body: some View {
        HStack {
            deviceButton

            detailsButton
        }
            .navigationDestination(item: $presentingActiveDevice) { item in
                EEGDeviceDetails(device: item)
            }
            .accessibilityRepresentation {
                let button = Button(action: {
                    deviceButtonAction()
                }) {
                    Text(verbatim: device.model) // currently, this order flows best for Muse device naming
                    Text(verbatim: device.name)
                    if device.connectionState.associatedConnection {
                        Text(device.connectionState.localizedStringResource)
                    }
                }

                // accessibility actions cannot be unit tested
                if !FeatureFlags.renderAccessibilityActions {
                    if let connectedDevice, connectedDevice.state.establishedConnection {
                        button.accessibilityAction(named: "DEVICE_DETAILS", {
                            detailsButtonAction(for: connectedDevice)
                        })
                    } else {
                        button
                    }
                } else {
                    HStack {
                        button
                            .frame(maxWidth: .infinity)
                        detailsButton
                    }
                }
            }
    }


    @MainActor @ViewBuilder private var deviceButton: some View {
        Button(action: {
            deviceButtonAction()
        }) {
            HStack {
                Text(verbatim: "\(device.model) - \(device.name)")
                    .foregroundColor(.primary)
                Spacer()

                if let connectedDevice {
                    switch connectedDevice.state {
                    case .connecting:
                        ProgressView()
                    case .connected:
                        Text("CONNECTED")
                            .foregroundStyle(.gray)
                    case .interventionRequired:
                        Text("ATTENTION_REQUIRED")
                            .foregroundStyle(.gray)
                    default:
                        EmptyView()
                    }
                }
            }
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder private var detailsButton: some View {
        if let connectedDevice, connectedDevice.state.establishedConnection {
            Button("DEVICE_DETAILS", systemImage: "info.circle") {
                detailsButtonAction(for: connectedDevice)
            }
                .labelStyle(.iconOnly)
                .font(.title3)
                .buttonStyle(.plain) // ensure button is clickable next to the other button
                .foregroundColor(.accentColor)
        }
    }


    init(eegModel: EEGViewModel, device: EEGDevice) {
        self.device = device
        self.eegModel = eegModel
    }


    @MainActor
    private func deviceButtonAction() {
        eegModel.tapDevice(device)
    }

    private func detailsButtonAction(for device: ConnectedDevice) {
        presentingActiveDevice = device
    }
}


#if DEBUG
#Preview {
    let device = MockEEGDevice(name: "Device", model: "Mock")
    let model = EEGViewModel(deviceManager: MockDeviceManager())

    return NavigationStack {
        List {
            EEGDeviceRow(eegModel: model, device: device) // tap to pair
        }
    }
}

#Preview {
    NavigationStack {
        List {
            EEGDeviceRow(
                eegModel: EEGViewModel(deviceManager: MockDeviceManager()),
                device: MockEEGDevice(name: "Nearby Device", model: "Mock")
            )
        }
    }
}

#Preview {
    let devices = [
        MockEEGDevice(name: "Device 1", model: "Mock", state: .connecting),
        MockEEGDevice(name: "Device 2", model: "Mock", state: .connected),
        MockEEGDevice(name: "Device 3", model: "Mock", state: .interventionRequired("Firmware update required."))
    ]

    return ForEach(devices, id: \.macAddress) { device in
        NavigationStack {
            List {
                EEGDeviceRow(eegModel: EEGViewModel(mock: device), device: device)
            }
        }
    }
}
#endif
