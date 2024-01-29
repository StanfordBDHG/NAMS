//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseBatteryDetailsSection: View {
    private let deviceInformation: MuseDeviceInformation

    var body: some View {
        if let remainingBattery = deviceInformation.remainingBatteryPercentage {
            Section {
                ListRow("BATTERY") {
                    BatteryIcon(percentage: Int(remainingBattery))
                }
            } footer: {
                MuseBatteryProblemsHint()
            }
        }
    }


    init(_ deviceInformation: MuseDeviceInformation) {
        self.deviceInformation = deviceInformation
    }
}


#if DEBUG
#Preview {
    List {
        MuseBatteryDetailsSection(
            .init(serialNumber: "", firmwareVersion: "", hardwareVersion: "", remainingBatteryPercentage: 75)
        )
    }
}
#endif
