//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public enum Alignment { // TODO: better name?
    case horizontal
    case vertical
}

extension Alignment: PreferenceKey {
    public typealias Value = Self?

    public static func reduce(value: inout Self?, nextValue: () -> Self?) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}


public struct DynamicHStack<Content: View>: View { // TODO: move to Spezi Views
    private let realignAfter: DynamicTypeSize
    private let verticalAlignment: VerticalAlignment
    private let horizontalAlignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: Content

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize


    public var body: some View {
        if dynamicTypeSize <= realignAfter {
            HStack(alignment: verticalAlignment, spacing: spacing) {
                content
            }
                .preference(key: Alignment.self, value: .horizontal)
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                content
            }
                .preference(key: Alignment.self, value: .vertical)
        }
    }


    public init(
        realignAfter: DynamicTypeSize = .xxLarge,
        verticalAlignment: VerticalAlignment = .center,
        horizontalAlignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.realignAfter = realignAfter
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.content = content()
    }
}


public struct ListRow<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content


    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @State private var alignment: Alignment?


    public var body: some View {
        HStack {
            DynamicHStack(horizontalAlignment: .leading) {
                label
                    .foregroundColor(.primary)
                    .lineLimit(alignment == .horizontal ? 1 : nil)

                if alignment == .horizontal {
                    Spacer()
                }

                content
                    .lineLimit(alignment == .horizontal ? 1 : nil)
                    .layoutPriority(1)
                    .foregroundColor(.secondary)
            }

            if alignment == .vertical {
                Spacer()
            }
        }
            .accessibilityElement(children: .combine)
            .onPreferenceChange(Alignment.self) { value in
                alignment = value
            }
    }


    public init(verbatim label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(label, content: content)
    }

    @_disfavoredOverload
    public init(_ label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(verbatim: label) }, content: content)
    }

    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(label) }, content: content)
    }


    // TODO: make arbitrary label view!
    public init(@ViewBuilder _ label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
}


#if DEBUG
#Preview {
    List {
        ListRow(verbatim: "Hello") {
            Text(verbatim: "World")
        }

        HStack {
            ListRow(verbatim: "Device") {
                EmptyView()
            }
            ProgressView()
        }

        HStack {
            ListRow(verbatim: "Device") {
                Text(verbatim: "World")
            }
            ProgressView()
                .padding(.leading, 6)
        }

        HStack {
            ListRow(verbatim: "Long Device Name") {
                Text(verbatim: "Long Description")
            }
            ProgressView()
                .padding(.leading, 4)
        }
    }
}
#endif
