//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MuseAboutDetailsSection: View {
    private let deviceInformation: MuseDeviceInformation


    var body: some View {
        Section("About") {
            ListRow("Firmware Version") {
                Text(verbatim: deviceInformation.firmwareVersion)
            }
            ListRow("Hardware Version") {
                Text(verbatim: deviceInformation.hardwareVersion)
            }
            ListRow("Serial Number") {
                Text(verbatim: deviceInformation.serialNumber)
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
        MuseAboutDetailsSection(
            .init(serialNumber: "0xAABBCC", firmwareVersion: "1.2", hardwareVersion: "20.1")
        )
    }
}
#endif
