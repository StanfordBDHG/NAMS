//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AutoConnectConfigurationView: View {
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator

    var body: some View {
        @Bindable var deviceCoordinator = deviceCoordinator
        List {
            Section {
                Picker(selection: $deviceCoordinator.autoConnectOption) {
                    Text("Off").tag(AutoConnectConfiguration.off)
                    Text("On").tag(AutoConnectConfiguration.on)
                    Text("Search in Background").tag(AutoConnectConfiguration.background)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } footer: {
                Text("Automatically connect to nearby SensoMedical BIOPOT3 devices.")
                    + Text(verbatim: "\n")
                    + Text("If background search is enabled, the application will search for nearby devices until a devices was found and connected.")
            }
        }
            .navigationTitle("Auto Connect")
            .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    NavigationStack {
        AutoConnectConfigurationView()
    }
        .environment(DeviceCoordinator())
}
