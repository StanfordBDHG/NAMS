//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

#if canImport(SpeziQuestionnaire)
import SpeziViews
import SwiftUI


struct ScreeningTileHeader: View {
    private static let iconRealignSize: DynamicTypeSize = .accessibility3

    private let task: ScreeningTask

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass // for iPad or landscape we want to stay horizontal

    @State private var subheadlineLayout: DynamicLayout?

    private var iconGloballyPlaced: Bool {
        horizontalSizeClass == .regular || dynamicTypeSize < Self.iconRealignSize
    }

    var body: some View {
        HStack {
            if iconGloballyPlaced {
                clipboard
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if !iconGloballyPlaced {
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
        DynamicHStack(realignAfter: .xxxLarge) {
            Text(task.tileType.localizedStringResource)

            if subheadlineLayout == .horizontal {
                Spacer()
            }

            Text("\(task.expectedCompletionMinutes) min", comment: "Expected task completion in minutes.")
                .accessibilityLabel("takes \(task.expectedCompletionMinutesSpoken) min")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .accessibilityElement(children: .combine)
        .onPreferenceChange(DynamicLayout.self) { layout in
            subheadlineLayout = layout
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
#endif
