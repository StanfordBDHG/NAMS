//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

#if canImport(SpeziQuestionnaire)
import SpeziQuestionnaire
import SpeziViews
import SwiftUI


@MainActor
struct ScreeningTile: View {
    private let task: ScreeningTask

    @Environment(PatientListModel.self)
    private var patientList

    @Binding private var presentingItem: Questionnaire?

    @MainActor private var completed: Bool {
        patientList.completedTaskIds?.contains(task.id) == true
    }

    var body: some View {
        if completed {
            SimpleTile {
                CompletedTileHeader {
                    Text(task.title)
                }
            } body: {
                Text(task.completedDescription)
            }
        } else {
            SimpleTile {
                TileHeader {
                    Image(systemName: "list.bullet.clipboard")
                        .foregroundColor(.mint)
                        .font(.custom("Screening Task Icon", size: 30, relativeTo: .headline))
                        .accessibilityHidden(true)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                } title: {
                    Text(task.title)
                } subheadline: {
                    subheadline
                }
            } body: {
                Text(task.description)
                    .font(.callout)
            } footer: {
                Button {
                    presentingItem = task.questionnaire
                } label: {
                    Text("Start \(task.tileType.localizedStringResource)")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                    .buttonStyle(.borderedProminent)
            }
                .tint(.mint)
        }
    }

    @ViewBuilder private var subheadline: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text(task.tileType.localizedStringResource)
                Spacer()
                expectedCompletion
            }
                .lineLimit(1)
                .accessibilityElement(children: .combine)

            VStack {
                Text(task.tileType.localizedStringResource)
                expectedCompletion
            }
                .lineLimit(1)
                .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder private var expectedCompletion: some View {
        Text("\(task.expectedCompletionMinutes) min", comment: "Expected task completion in minutes.")
            .accessibilityLabel("takes \(task.expectedCompletionMinutesSpoken) min")
    }


    init(task: ScreeningTask, presentingItem: Binding<Questionnaire?>) {
        self.task = task
        self._presentingItem = presentingItem
    }
}


#if DEBUG
#Preview {
    List {
        ScreeningTile(task: .mChatRF, presentingItem: .constant(nil))
            .previewWith {
                PatientListModel()
            }
    }
}

#Preview {
    let patientList = PatientListModel()
    patientList.completedTasks = [
        CompletedTask(
            taskId: ScreeningTask.mChatRF.id,
            content: .questionnaireResponse(.init(status: .init()))
        )
    ]

    return List {
        ScreeningTile(task: .mChatRF, presentingItem: .constant(nil))
            .environment(patientList)
    }
}
#endif

#endif
