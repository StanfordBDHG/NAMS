//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseDeviceDetailsView: View {
    private let model: String
    private let state: ConnectionState
    private let deviceInformation: MuseDeviceInformation?
    private let disconnectClosure: () -> Void

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        List {
            if case let .interventionRequired(message) = state {
                MuseInterventionRequiredHint(message)
            }

            if let deviceInformation {
                MuseBatteryDetailsSection(deviceInformation)
                MuseHeadbandFitSection(deviceInformation)
                MuseAboutDetailsSection(deviceInformation)
            }

            Button(action: {
                disconnectClosure()
            }) {
                Text("Disconnect")
                    .frame(maxWidth: .infinity)
            }
                .disabled(!state.associatedConnection)
        }
            .navigationTitle(Text(verbatim: model))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: state) {
                if state == .disconnected {
                    dismiss()
                }
            }
    }


    init(model: String, state: ConnectionState, _ deviceInformation: MuseDeviceInformation?, disconnect: @escaping () -> Void) {
        self.model = model
        self.state = state
        self.deviceInformation = deviceInformation
        self.disconnectClosure = disconnect
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .connected,
            .mock(wearingHeadband: true, fit: HeadbandFit(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .poor, tp10Fit: .good))
        ) {
            print("Disconnect Device")
        }
    }
}

#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .connected,
            .mock()
        ) {
            print("Disconnect Device")
        }
    }
}

#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .interventionRequired("INTERVENTION_MUSE_FIRMWARE"),
            .mock()
        ) {
            print("Disconnect Device")
        }
    }
}

#Preview {
    NavigationStack {
        MuseDeviceDetailsView(
            model: "Mock Device",
            state: .disconnected,
            nil
        ) {
            print("Disconnect Device")
        }
    }
}
#endif
