//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseBatteryProblemsHint: View {
    @Environment(\.locale)
    private var locale

    var body: some View {
        HStack {
            let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
            Text("PROBLEMS_BATTERY_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Muse-Battery-Troubleshooting?language=\(locale.identifier))")
        }
    }

    init() {}
}


#if DEBUG
#Preview {
    MuseBatteryProblemsHint()
}
#endif
