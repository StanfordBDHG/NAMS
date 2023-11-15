//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct BIOPOT: View {
    @EnvironmentObject private var biopot: BiopotDevice

    var body: some View {
        if let info = biopot.deviceInfo {
            List {
                ListRow("Device") {
                    Text("Connected")
                }

                Section("Status") {
                    ListRow("BATTERY") {
                        BatteryIcon(percentage: Int(info.batteryLevel))
                    }
                    ListRow("Charging") {
                        if info.batteryCharging {
                            Text("Yes")
                        } else {
                            Text("No")
                        }
                    }
                    ListRow("Temperature") {
                        Text("\(info.temperatureValue) °C")
                    }
                }
                .onAppear {
                    // TODO: we currently cannot read values through SpeziBluetooth!
                }
            }
        } else {
            VStack {
                Text("No Device Connected")
                    .font(.title)
                Text("No BioPot device found. Please make sure the device is turned on.")
            }
        }
    }
}


#if DEBUG
#Preview {
    BIOPOT()
        .environmentObject(BiopotDevice()) // TODO: that works as long as we don't touch the Dependency
}
#endif
