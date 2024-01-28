//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


#if MUSE
struct MuseDeviceList: View {
    @Environment(MuseDeviceManager.self)
    private var museDeviceManager

    var body: some View {
        ForEach(museDeviceManager.nearbyMuses) { device in
            MuseDeviceRow(device: device)
        }
    }

    
    init() {}
}
#endif


/*
 //TODO: move to mock preview? 
#if DEBUG
#Preview {
    NavigationStack {
        List {
            MuseDeviceList()
        }
    }
        .environment(EEGViewModel(deviceManager: MockDeviceManager(immediate: true)))
}
#endif
*/
