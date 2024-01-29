//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct BiopotDeviceDetailsView: View {
    private let biopot: BiopotDevice
    private let disconnectClosure: () -> Void

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
            if let info = biopot.service.deviceInfo {
                Section {
                    ListRow("BATTERY") {
                        BatteryIcon(percentage: Int(info.batteryLevel), isCharging: info.batteryCharging)
                    }
                }
            }

            Section("About") {
                if let firmware = biopot.deviceInformation.firmwareRevision {
                    ListRow("Firmware Version") {
                        Text(verbatim: firmware)
                    }
                }
                if let hardware = biopot.deviceInformation.hardwareRevision {
                    ListRow("Hardware Version") {
                        Text(verbatim: hardware)
                    }
                }
                if let serialNumber = biopot.deviceInformation.serialNumber {
                    ListRow("Serial Number") {
                        Text(verbatim: serialNumber)
                    }
                }
            }

            Button(action: {
                disconnectClosure()
                dismiss()
            }) {
                Text("Disconnect")
                    .frame(maxWidth: .infinity)
            }
                .disabled(biopot.state == .disconnected || biopot.state == .disconnecting)
        }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text(verbatim: biopot.name ?? ""))
            .onChange(of: biopot.state) {
                if biopot.state == .disconnected || biopot.state == .disconnecting {
                    dismiss()
                }
            }
    }


    init(device: BiopotDevice, disconnect: @escaping () -> Void) {
        self.biopot = device
        self.disconnectClosure = disconnect
    }
}


// TODO: preview
