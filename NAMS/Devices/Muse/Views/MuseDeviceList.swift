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

    @Binding private var path: NavigationPath

    var body: some View {
        ForEach(museDeviceManager.nearbyMuses) { device in
            MuseDeviceRow(device: device, path: $path)
        }
    }

    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
}
#endif
