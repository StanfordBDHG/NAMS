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

    @ObservedObject private var eegModel: EEGViewModel

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
                let button = Button(action: deviceButtonAction) {
                    Text(verbatim: device.model) // currently, this order flows best for Muse device naming
                    Text(verbatim: device.name)
                    if device.connectionState.associatedConnection {
                        Text(device.connectionState.localizedStringResource)
                    }
                }

                if !FeatureFlags.testBLEDevices {
                    if let connectedDevice, connectedDevice.state.establishedConnection {
                        button.accessibilityAction(named: "DEVICE_DETAILS", {
                            detailsButtonAction(for: connectedDevice)
                        })
                    } else {
                        button
                    }
                } else { // accessibility actions cannot be unit tested
                    button
                    detailsButton
                }
            }
    }

    @ViewBuilder private var deviceButton: some View {
        let button = Button(action: deviceButtonAction) {
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

        // this is such that the button spans the whole list row but doesn't cover the details button when it's present
        if connectedDevice?.state.establishedConnection == true {
            button
                .buttonStyle(.plain)
        } else {
            button
        }
    }

    @ViewBuilder private var detailsButton: some View {
        if let connectedDevice, connectedDevice.state.establishedConnection {
            Button("DEVICE_DETAILS", systemImage: "info.circle") {
                detailsButtonAction(for: connectedDevice)
            }
                .labelStyle(.iconOnly)
                .font(.title3)
        }
    }


    init(eegModel: EEGViewModel, device: EEGDevice) {
        self.device = device
        self.eegModel = eegModel
    }


    private func deviceButtonAction() {
        eegModel.tapDevice(device)
    }

    private func detailsButtonAction(for device: ConnectedDevice) {
        presentingActiveDevice = device
    }
}


#if DEBUG
struct EEGDeviceRow_Previews: PreviewProvider {
    struct StateRow: View {
        static let device = MockEEGDevice(name: "Device", model: "Mock")
        @StateObject var model = EEGViewModel(deviceManager: MockDeviceManager())
        var body: some View {
            EEGDeviceRow(eegModel: model, device: Self.device)
        }
    }

    static let devices = [
        MockEEGDevice(name: "Device 1", model: "Mock", state: .connecting),
        MockEEGDevice(name: "Device 2", model: "Mock", state: .connected),
        MockEEGDevice(name: "Device 3", model: "Mock", state: .interventionRequired("Firmware update required."))
    ]

    static var previews: some View {
        NavigationStack {
            List {
                StateRow() // tap to pair
            }
        }

        NavigationStack {
            List {
                EEGDeviceRow(
                    eegModel: EEGViewModel(deviceManager: MockDeviceManager()),
                    device: MockEEGDevice(name: "Nearby Device", model: "Mock")
                )
            }
        }

        ForEach(devices, id: \.macAddress) { device in
            NavigationStack {
                List {
                    EEGDeviceRow(eegModel: EEGViewModel(mock: device), device: device)
                }
            }
        }
    }
}
#endif
