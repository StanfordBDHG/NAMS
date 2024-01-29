//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseHeadbandFitView: View {
    private let fit: HeadbandFit


    var body: some View {
        List {
            ListRow("Overall") {
                FitLabel(fit.overallFit)
            }

            Section {
                ListRow("TP9") {
                    FitLabel(fit.tp9Fit)
                }
                ListRow("AF7") {
                    FitLabel(fit.af7Fit)
                }
                ListRow("AF8") {
                    FitLabel(fit.af8Fit)
                }
                ListRow("TP10") {
                    FitLabel(fit.tp10Fit)
                }
            } header: {
                Text("Channels")
            } footer: {
                MuseHeadbandFitProblemsHint()
            }
        }
            .navigationTitle("Headband Fit")
            .navigationBarTitleDisplayMode(.inline)
    }


    init(_ fit: HeadbandFit) {
        self.fit = fit
    }
}


#Preview {
    NavigationStack {
        MuseHeadbandFitView(.init(tp9Fit: .good, af7Fit: .mediocre, af8Fit: .good, tp10Fit: .poor))
    }
}
