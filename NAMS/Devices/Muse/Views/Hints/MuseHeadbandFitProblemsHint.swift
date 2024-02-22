//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseHeadbandFitProblemsHint: View {
    @Environment(\.locale)
    private var locale

    var body: some View {
        HStack {
            let troubleshooting: LocalizedStringResource = "TROUBLESHOOTING"
            Text("PROBLEMS_HEADBAND_FIT_HINT") + Text(" [\(troubleshooting)](https://choosemuse.my.site.com/s/article/Sensor-Quality-Troubleshooting?language=\(locale.identifier))")
        }
    }

    init() {}
}


#if DEBUG
#Preview {
    MuseHeadbandFitProblemsHint()
}
#endif
