//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CompletedTile<Title: View, Description: View>: View {
    private let title: Title
    private let description: Description

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 30))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                title
                    .font(.headline)

                Text("Completed", comment: "Completed Tile. Subtitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            description
                .font(.callout)
        }
            .containerShape(Rectangle())
    }

    init(@ViewBuilder title: () -> Title, @ViewBuilder description: () -> Description) {
        self.title = title()
        self.description = description()
    }
}


#if DEBUG
#Preview {
    CompletedTile {
        Text(verbatim: "Test Task")
    } description: {
        Text(verbatim: "A nice description of a test task.")
    }
}
#endif
