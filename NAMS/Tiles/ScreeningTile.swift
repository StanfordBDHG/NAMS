//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
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
            CompletedTile {
                Text(task.title)
                    .font(.headline)
            } description: {
                Text(task.completedDescription)
                    .font(.callout)
            }
        } else {
            SimpleTile {
                tileHeader
            } footer: {
                Text(task.description)
                    .font(.callout)

                Button(action: {
                    presentingItem = task.questionnaire
                }) {
                    Text("Start \(task.tileType.localizedStringResource)")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                    .tint(.mint)
            }
        }
    }

    @ViewBuilder private var tileHeader: some View {
        HStack {
            Image(systemName: "list.bullet.clipboard")
                .foregroundColor(.mint)
                .font(.custom("Screening Task Icon", size: 30, relativeTo: .headline))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)

                HStack {
                    Text(task.tileType.localizedStringResource)

                    Spacer()
                    Text("\(task.expectedCompletionMinutes) min", comment: "Expected task completion in minutes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityElement(children: .combine)
            }
        }
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
            .environment(PatientListModel())
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
