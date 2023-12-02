//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EEGDeviceList: View {
    private let eegModel: EEGViewModel

    var sortedDeviceList: [EEGDevice] {
        eegModel.nearbyDevices.sorted { lhs, rhs in
            lhs.name < rhs.name
        }
    }

    var body: some View {
        ForEach(sortedDeviceList, id: \.macAddress) { device in
            EEGDeviceRow(eegModel: eegModel, device: device)
        }
    }

    
    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }
}


#if DEBUG
#Preview {
    let model = EEGViewModel(deviceManager: MockDeviceManager(immediate: true))
    return List {
        EEGDeviceList(eegModel: model)
    }
}
#endif
