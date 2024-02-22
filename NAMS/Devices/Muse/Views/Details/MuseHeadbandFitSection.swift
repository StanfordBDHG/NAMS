//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MuseHeadbandFitSection: View {
    private let deviceInformation: MuseDeviceInformation


    var body: some View {
        Section {
            ListRow("WEARING") {
                if deviceInformation.wearingHeadband {
                    Text("Yes")
                } else {
                    Text("No")
                }
            }

            if deviceInformation.wearingHeadband,
               let fit = deviceInformation.fit {
                NavigationLink {
                    MuseHeadbandFitView(fit)
                } label: {
                    ListRow("Headband Fit") {
                        FitLabel(fit.overallFit)
                    }
                }
            }
        } header: {
            Text("Headband")
        } footer: {
            MuseHeadbandFitProblemsHint()
        }
    }


    init(_ deviceInformation: MuseDeviceInformation) {
        self.deviceInformation = deviceInformation
    }
}


#if DEBUG
#Preview {
    let fit = HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .good, tp10Fit: .good)
    return NavigationStack {
        List {
            MuseHeadbandFitSection(
                .init(serialNumber: "0xAABBCC", firmwareVersion: "1.2", hardwareVersion: "20.1", wearingHeadband: true, fit: fit)
            )
        }
    }
}

#Preview {
    let fit = HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .good, tp10Fit: .mediocre)
    return NavigationStack {
        List {
            MuseHeadbandFitSection(
                .init(serialNumber: "0xAABBCC", firmwareVersion: "1.2", hardwareVersion: "20.1", wearingHeadband: true, fit: fit)
            )
        }
    }
}

#Preview {
    let fit = HeadbandFit(tp9Fit: .poor, af7Fit: .mediocre, af8Fit: .poor, tp10Fit: .mediocre)
    return NavigationStack {
        List {
            MuseHeadbandFitSection(
                .init(serialNumber: "0xAABBCC", firmwareVersion: "1.2", hardwareVersion: "20.1", wearingHeadband: true, fit: fit)
            )
        }
    }
}

#Preview {
    NavigationStack {
        List {
            MuseHeadbandFitSection(
                .init(serialNumber: "0xAABBCC", firmwareVersion: "1.2", hardwareVersion: "20.1")
            )
        }
    }
}
#endif
