//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR
import SwiftUI


@MainActor
struct QuestionnaireTile: View {
    private let patientQuestionnaire: PatientQuestionnaire

    @Environment(PatientListModel.self)
    private var patientList

    @Binding private var presentingItem: Questionnaire?

    @MainActor private var completed: Bool {
        patientList.completedQuestionnaires?.contains(patientQuestionnaire.id) == true
    }

    var body: some View {
        VStack(alignment: .leading) {
            tileHeader

            Divider()

            Text(patientQuestionnaire.description)
                .font(.callout)

            if !completed {
                Button(action: {
                    presentingItem = patientQuestionnaire.questionnaire
                }) {
                    Text("Start \(patientQuestionnaire.tileType.localizedStringResource)")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
            .containerShape(Rectangle())
    }

    @ViewBuilder private var tileHeader: some View {
        HStack {
            if completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 30))
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.mint)
                    .font(.system(size: 30))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(patientQuestionnaire.title)
                    .font(.headline)
                    .accessibilityLabel(
                        completed
                        ? "Completed Task: \(patientQuestionnaire.title)"
                        : "Task: \(patientQuestionnaire.title)"
                    )

                HStack {
                    if completed {
                        Text("Completed", comment: "Completed Task. Subtitle.")
                    } else {
                        Text(patientQuestionnaire.tileType.localizedStringResource)

                        Spacer()
                        Text("\(patientQuestionnaire.expectedCompletionMinutes) min", comment: "Expected task completion in minutes.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
    }


    init(patientQuestionnaire: PatientQuestionnaire, presentingItem: Binding<Questionnaire?>) {
        self.patientQuestionnaire = patientQuestionnaire
        self._presentingItem = presentingItem
    }
}


#if DEBUG
#Preview {
    List {
        QuestionnaireTile(patientQuestionnaire: .mChatRF, presentingItem: .constant(nil))
            .environment(PatientListModel())
    }
}
#endif
