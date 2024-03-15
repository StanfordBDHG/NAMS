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


struct BiopotCustomElectrodePicker: View {
    private let keyPath: WritableKeyPath<BiopotElectrodeLocations, EEGLocation>
    @Binding private var customLocations: BiopotElectrodeLocations

    private var selection: Binding<EEGLocation> {
        .init {
            customLocations[keyPath: keyPath]
        } set: { location in
            customLocations[keyPath: keyPath] = location
        }
    }

    var body: some View {
        Picker(selection: selection) {
            ForEach(EEGLocation.allCases) { location in
                Text(verbatim: location.rawValue)
                    .tag(location)
            }
        } label: {
            Text("Channel \(keyPath.channelNumber)")
        }
    }


    init(for keyPath: WritableKeyPath<BiopotElectrodeLocations, EEGLocation>, locations customLocations: Binding<BiopotElectrodeLocations>) {
        self.keyPath = keyPath
        self._customLocations = customLocations
    }
}


#if DEBUG
#Preview {
    @Bindable var configuration = BiopotDeviceConfiguration()
    return List {
        BiopotCustomElectrodePicker(for: \.channel1, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel2, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel3, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel4, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel5, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel6, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel7, locations: $configuration.customElectrodesLocations)
        BiopotCustomElectrodePicker(for: \.channel8, locations: $configuration.customElectrodesLocations)
    }
}
#endif
