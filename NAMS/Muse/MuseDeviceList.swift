//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseDeviceList: View {
    @ObservedObject private var museModel: MuseViewModel

    var sortedDeviceList: [IXNMuse] {
        museModel.nearbyMuses.sorted { lhs, rhs in
            let lhsValue = lhs.getConnectionState().rawValue == 0 ? 3 : lhs.getConnectionState().rawValue
            let rhsValue = rhs.getConnectionState().rawValue == 0 ? 3 : rhs.getConnectionState().rawValue
            return lhsValue < rhsValue
        }
    }

    var body: some View {
        // TODO don't rely on index;
        let list = sortedDeviceList

        ForEach(list.indices, id: \.self) { index in
            let muse = list[index]
            MuseDeviceRow(museModel: museModel, muse: muse)
        }
    }

    init(museModel: MuseViewModel) {
        self.museModel = museModel
    }
}


#if DEBUG
struct MuseDeviceList_Previews: PreviewProvider {
    @StateObject static var model = MuseViewModel()
    static var previews: some View {
        NavigationStack {
            NearbyDevices(museModel: model)
        }
    }
}
#endif
