//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ScreeningTileHeader: View {
    private static let iconRealignSize: DynamicTypeSize = .accessibility3

    private let task: ScreeningTask

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @State private var subheadlineAlignment: Alignment?

    var body: some View {
        HStack {
            if dynamicTypeSize < Self.iconRealignSize {
                clipboard
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if dynamicTypeSize >= Self.iconRealignSize {
                        clipboard
                    }
                    Text(task.title)
                        .font(.headline)
                }
                subheadline
            }
        }
    }

    @ViewBuilder var clipboard: some View {
        Image(systemName: "list.bullet.clipboard")
            .foregroundColor(.mint)
            .font(.custom("Screening Task Icon", size: 30, relativeTo: .headline))
            .accessibilityHidden(true)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    @ViewBuilder var subheadline: some View {
        DynamicHStack(realignAfter: .xxxLarge, horizontalAlignment: .leading) {
            Text(task.tileType.localizedStringResource)

            if subheadlineAlignment == .horizontal {
                Spacer()
            }

            Text("\(task.expectedCompletionMinutes) min", comment: "Expected task completion in minutes.")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .accessibilityElement(children: .combine)
        .onPreferenceChange(Alignment.self) { alignment in
            subheadlineAlignment = alignment
        }
    }


    init(_ task: ScreeningTask) {
        self.task = task
    }
}


#if DEBUG
#Preview {
    List {
        ScreeningTileHeader(.mChatRF)
    }
}
#endif
