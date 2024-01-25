//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ListRow<Value: View>: View {
    private let name: Text
    private let value: Value

    var body: some View {
        HStack {
            name
            Spacer()
            value
                .foregroundColor(.secondary)
        }
            .accessibilityElement(children: .combine)
    }

    @_disfavoredOverload
    init(_ string: String, @ViewBuilder value: () -> Value) {
        self.name = Text(verbatim: string)
        self.value = value()
    }

    init(_ name: LocalizedStringResource, @ViewBuilder value: () -> Value) {
        self.name = Text(name)
        self.value = value()
    }
}


#if DEBUG
#Preview {
    List {
        ListRow("Hello") {
            Text(verbatim: "World")
        }
    }
}
#endif
