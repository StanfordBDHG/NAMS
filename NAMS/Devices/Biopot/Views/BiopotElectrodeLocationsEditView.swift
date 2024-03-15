//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import SpeziViews
import SwiftUI


struct BiopotElectrodeLocationsEditView: View {
    private let biopot: BiopotDevice

    var body: some View {
        @Bindable var configuration = biopot.configuration
        List {
            Section {
                Picker(selection: $configuration.electrodeSelection) {
                    Text("Cap").tag(PredefinedElectrodeLocation.cap)
                    Text("Paper").tag(PredefinedElectrodeLocation.paper)
                    Text("Custom").tag(PredefinedElectrodeLocation.custom)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } footer: {
                Text("You can select a predefined electrode assignment or provide a custom one.")
            }

            Section("Assignment") {
                if configuration.electrodeSelection == .custom {
                    BiopotCustomElectrodePicker(for: \.channel1, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel2, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel3, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel4, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel5, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel6, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel7, locations: $configuration.customElectrodesLocations)
                    BiopotCustomElectrodePicker(for: \.channel8, locations: $configuration.customElectrodesLocations)
                } else {
                    displayChannel(location: \.channel1)
                    displayChannel(location: \.channel2)
                    displayChannel(location: \.channel3)
                    displayChannel(location: \.channel4)
                    displayChannel(location: \.channel5)
                    displayChannel(location: \.channel6)
                    displayChannel(location: \.channel7)
                    displayChannel(location: \.channel8)
                }
            }
        }
            .navigationTitle("Electrode Locations")
            .navigationBarTitleDisplayMode(.inline)
    }


    init(biopot: BiopotDevice) {
        self.biopot = biopot
    }


    @ViewBuilder
    func displayChannel(location: KeyPath<BiopotElectrodeLocations, EEGLocation>) -> some View {
        ListRow("Channel \(location.channelNumber)") {
            Text(verbatim: biopot.configuration.electrodeLocations[keyPath: location].rawValue)
        }
    }
}


extension KeyPath where Root == BiopotElectrodeLocations, Value == EEGLocation {
    var channelNumber: Int {
        switch self {
        case \.channel1:
            1
        case \.channel2:
            2
        case \.channel3:
            3
        case \.channel4:
            4
        case \.channel5:
            5
        case \.channel6:
            6
        case \.channel7:
            7
        case \.channel8:
            8
        default:
            preconditionFailure("Unexpected keyPath for channel: \(self)")
        }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        BiopotElectrodeLocationsEditView(biopot: BiopotDevice.createMock())
    }
}
#endif
