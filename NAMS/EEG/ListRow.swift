//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ListRow<Value: View>: View {
    private let name: LocalizedStringResource
    private let value: Value

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            value
                .foregroundColor(.secondary)
        }
            .accessibilityElement(children: .combine)
    }

    init(_ name: LocalizedStringResource, @ViewBuilder value: () -> Value) {
        self.name = name
        self.value = value()
    }
}


#if DEBUG
struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        ListRow("Hello") {
            Text("World")
        }
    }
}
#endif
