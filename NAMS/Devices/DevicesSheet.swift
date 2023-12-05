//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth
import SwiftUI


private enum DeviceType: String, CaseIterable, CustomLocalizedStringResourceConvertible, Hashable {
    case muse
    case biopot

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .muse:
            "Muse"
        case .biopot:
            "Biopot"
        }
    }
}


struct DevicesSheet: View {
    private let eegModel: EEGViewModel

    @State private var selectedDevice: DeviceType = .muse

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Device Type", selection: $selectedDevice) {
                        ForEach(DeviceType.allCases, id: \.self) { type in
                            Text(type.localizedStringResource)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                    .listSectionSpacing(.compact)

                switch selectedDevice {
                case .muse:
                    NearbyDevices(eegModel: eegModel)
                case .biopot:
                    Biopot()
                }
            }
                .navigationTitle("NEARBY_DEVICES")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
        }
    }


    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }
}


#if DEBUG
#Preview {
    DevicesSheet(eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
        .biopotPreviewSetup()
}
#endif
