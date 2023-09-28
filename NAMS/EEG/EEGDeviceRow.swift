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

    var body: some View {
        HStack {
            Button(action: {
                eegModel.tapDevice(device)
            }) {
                HStack {
                    Text(verbatim: "\(device.model) - \(device.name.replacingOccurrences(of: "Muse-", with: ""))") // TODO replacing occurences not here!
                        .foregroundColor(.primary)
                    Spacer()
                    if let connectedDevice {
                        if connectedDevice.state == .connecting {
                            ProgressView()
                        } else if connectedDevice.state == .connected || connectedDevice.state == .interventionRequired {
                            Text("Connected") // TODO improve accessibility?
                                .foregroundStyle(.secondary)

                            if connectedDevice.state == .interventionRequired {
                                // TODO shall this be tapable?
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                    }
                }
            }
                .buttonStyle(.plain)

            // TODO maybe build a details view with: battery percentage, firmware versions, warnings (like firmware or other things)
            //  , mounted, firmware type?, serial number
            //   => checking the fit?

            // TODO generlized connected state?
            if let connectedDevice, connectedDevice.state == .connected || connectedDevice.state == .interventionRequired {
                Button(action: {
                    // TODO how to do navigation?
                    //  EEGDeviceDetails(device: activeDevice)
                    print("pressed!")
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                    // TODO accessibility label
                }
                // TODO invervention required marker! => exclamationmark.triangle.fill (.symbolRenderingMode(.multicolor))
            }
        }
    }


    init(eegModel: EEGViewModel, device: EEGDevice) {
        self.device = device
        self.eegModel = eegModel
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
        MockEEGDevice(name: "Device 3", model: "Mock", state: .interventionRequired)
    ]

    static var previews: some View {
        NavigationStack {
            List {
                StateRow() // tap to pair
            }
        }

        NavigationStack {
            List {
                EEGDeviceRow(eegModel: EEGViewModel(deviceManager: MockDeviceManager()), device: MockEEGDevice(name: "Nearby Device", model: "Mock"))
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
