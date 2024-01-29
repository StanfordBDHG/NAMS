//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseInterventionRequiredHint: View {
    private let message: LocalizedStringResource

    var body: some View {
        VStack {
            // swiftlint:disable:next accessibility_label_for_image
            let image = Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
            Text("\(image) ", comment: "Image prefix placeholder") // this cannot be verbatim
                + Text("INTERVENTION_REQUIRED_TITLE")
                    .fontWeight(.semibold)
                + Text(verbatim: "\n")
                + Text(message)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .accessibilityRepresentation {
                Text("INTERVENTION_REQUIRED_PREFIX \(message)")
            }
    }


    init(_ message: LocalizedStringResource) {
        self.message = message
    }
}


#if DEBUG
#Preview {
    MuseInterventionRequiredHint("INTERVENTION_MUSE_FIRMWARE")
}
#endif
