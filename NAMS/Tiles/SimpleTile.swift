//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SimpleTile<Header: View, Footer: View>: View {
    private let alignment: HorizontalAlignment
    private let header: Header
    private let footer: Footer

    var body: some View {
        VStack(alignment: alignment) {
            header

            if Footer.self != EmptyView.self {
                Divider()
                    .padding(.bottom, 4)

                footer
            }
        }
            .containerShape(Rectangle())
    }

    init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self.alignment = alignment
        self.header = header()
        self.footer = footer()
    }
}


#if DEBUG
#Preview {
    List {
        SimpleTile {
            Text(verbatim: "Test Tile Header")
        } footer: {
            Text(verbatim: "The description of a tile")
        }
    }
}

#Preview {
    List {
        SimpleTile {
            Text(verbatim: "Test Tile Header only")
        }
    }
}
#endif
