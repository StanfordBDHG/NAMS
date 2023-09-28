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

    var body: some View {
        HStack {
            Button(action: {
                eegModel.tapDevice(device)
            }) {
                HStack {
                    Text(verbatim: "\(device.model) - \(device.name.replacingOccurrences(of: "Muse-", with: ""))") // TODO replacing occurences not here!
                        .foregroundColor(.primary)
                    Spacer()
                }
            }

            // TODO maybe build a details view with: battery percentage, firmware versions, warnings (like firmware or other things)
            //  , mounted, firmware type?, serial number
            //   => checking the fit?

            if let activeDevice = eegModel.activeDevice,
               activeDevice.device.macAddress == device.macAddress {
                if let remainingBattery = activeDevice.remainingBatteryPercentage {
                    batteryIcon(percentage: remainingBattery)
                }

                // TODO access through the connected model?
                switch activeDevice.state {
                case .connecting:
                    ProgressView()
                case .connected:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true) // TODO accessibility!
                case .interventionRequired:
                    // TODO make this tapable! with information and instructions on how to update
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                    // TODO accessibility
                case .disconnected, .unknown:
                    EmptyView()
                }
            }
        }
    }


    init(eegModel: EEGViewModel, device: EEGDevice) {
        self.device = device
        self.eegModel = eegModel
    }


    @ViewBuilder
    func batteryIcon(percentage: Double) -> some View {
        Group {
            if percentage >= 90 {
                Image(systemName: "battery.100")
            } else if percentage >= 65 {
                Image(systemName: "battery.75")
            } else if percentage >= 40 {
                Image(systemName: "battery.50")
            } else if percentage >= 15 {
                Image(systemName: "battery.25")
            } else if percentage > 3 {
                Image(systemName: "battery.25")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
            } else {
                Image(systemName: "battery.0")
                    .foregroundColor(.red)
            }
        }
            .accessibilityLabel("Battery: \(percentage)%")
    }
}


#if DEBUG
struct EEGDeviceRow_Previews: PreviewProvider {
    struct StateRow: View {
        static let device = MockEEGDevice(name: "Device", model: "Mock")
        @StateObject var model = EEGViewModel(deviceManager: MockDeviceManager())
        var body: some View {
            EEGDeviceRow(eegModel: model, device:  Self.device)
        }
    }

    static let devices = [
        MockEEGDevice(name: "Connecting Device", model: "Mock", state: .connecting),
        MockEEGDevice(name: "Connected Device", model: "Mock", state: .connected),
        MockEEGDevice(name: "Connected Device", model: "Mock", state: .interventionRequired)
    ]

    static var previews: some View {
        List {
            StateRow() // tap to pair
        }

        List {
            EEGDeviceRow(eegModel: EEGViewModel(deviceManager: MockDeviceManager()), device: MockEEGDevice(name: "Nearby Device", model: "Mock"))
        }

        ForEach(devices, id: \.macAddress) { device in
            List {
                EEGDeviceRow(eegModel: EEGViewModel(mock: device), device: device)
            }
        }
    }
}
#endif
