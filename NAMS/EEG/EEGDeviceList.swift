//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EEGDeviceList: View {
    @ObservedObject private var eegModel: EEGViewModel

    var sortedDeviceList: [EEGDevice] {
        eegModel.nearbyDevices.sorted { lhs, rhs in
            let lhsValue = lhs.connectionState.rawValue == 0 ? 3 : lhs.connectionState.rawValue
            let rhsValue = rhs.connectionState.rawValue == 0 ? 3 : rhs.connectionState.rawValue
            return lhsValue < rhsValue
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
struct MuseDeviceList_Previews: PreviewProvider {
    @StateObject static var model = EEGViewModel(deviceManager: MockDeviceManager(nearbyDevices: [
        MockEEGDevice(name: "Mock", model: "Device 1"),
        MockEEGDevice(name: "Mock", model: "Device 2")
    ]))

    static var previews: some View {
        NavigationStack {
            NearbyDevices(eegModel: model)
        }
    }
}
#endif
