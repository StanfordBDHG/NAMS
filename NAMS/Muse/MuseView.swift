//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MuseView: View {
    @StateObject private var museModel = MuseViewModel()

    var body: some View {
        VStack {
            Text("Nearby Devices:")
            ForEach(museModel.nearbyMuses.indices, id: \.self) { index in
                Text(museModel.nearbyMuses[index].getName())
            }
        }
            .onAppear {
                museModel.startScanning()
            }
            .onDisappear {
                museModel.stopScanning()
            }
    }
}


#if DEBUG
struct MuseView_Previews: PreviewProvider {
    static var previews: some View {
        MuseView()
    }
}
#endif
