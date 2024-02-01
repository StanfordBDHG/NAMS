//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct LoadingSectionHeader: View {
    private let text: Text
    private let loading: Bool

    var body: some View {
        HStack {
            text
            if loading {
                ProgressView()
                    .padding(.leading, 4)
                    .accessibilityRemoveTraits(.updatesFrequently)
            }
        }
    }

    @_disfavoredOverload
    init(verbatim: String, loading: Bool) {
        self.init(Text(verbatim), loading: loading)
    }

    init(_ title: LocalizedStringResource, loading: Bool) {
        self.init(Text(title), loading: loading)
    }


    init(_ text: Text, loading: Bool) {
        self.text = text
        self.loading = loading
    }
}


#if DEBUG
#Preview {
    List {
        Section {
            Text(verbatim: "...")
        } header: {
            LoadingSectionHeader(verbatim: "Devices", loading: true)
        }
    }
}
#endif
