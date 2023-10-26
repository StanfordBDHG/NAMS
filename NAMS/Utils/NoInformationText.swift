//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct NoInformationText<Header: View, Caption: View>: View {
    private let header: Header
    private let caption: Caption

    var body: some View {
        VStack {
            header
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
            caption
                .padding([.leading, .trailing], 25)
                .foregroundColor(.secondary)
        }
            .multilineTextAlignment(.center)
    }

    init(@ViewBuilder header: () -> Header, @ViewBuilder caption: () -> Caption) {
        self.header = header()
        self.caption = caption()
    }
}


#if DEBUG
#Preview {
    NoInformationText {
        Text(verbatim: "No Information")
    } caption: {
        Text(verbatim: "Please add information to show some information.")
    }
}
#endif
