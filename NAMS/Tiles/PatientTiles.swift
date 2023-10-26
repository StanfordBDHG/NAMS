//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SpeziViews
import SwiftUI


@MainActor
struct PatientTiles: View {
    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle
    @State private var presentingQuestionnaire: Questionnaire?

    private var isPresentedBinding: Binding<Bool> {
        Binding {
            presentingQuestionnaire != nil
        } set: { newValue in
            if !newValue {
                presentingQuestionnaire = nil
            }
        }
    }

    private var questionnaires: [PatientQuestionnaire] {
        guard let completedList = patientList.completedQuestionnaires else {
            return PatientQuestionnaire.all
        }

        return PatientQuestionnaire.all.sorted { lhs, rhs in
            !completedList.contains(lhs.id) && completedList.contains(rhs.id)
        }
    }

    var body: some View {
        if patientList.questionnaires == nil {
            ProgressView()
        } else {
            List {
                Section("Screening") {
                    ForEach(questionnaires) { questionnaire in
                        QuestionnaireTile(patientQuestionnaire: questionnaire, presentingItem: $presentingQuestionnaire)
                    }
                }
            }
            .viewStateAlert(state: $viewState)
            .sheet(item: $presentingQuestionnaire) { questionnaire in
                QuestionnaireView(questionnaire: questionnaire, isPresented: isPresentedBinding) { response in
                    do {
                        try await patientList.add(response: response)
                    } catch {
                        viewState = .error(AnyLocalizedError(error: error))
                    }
                }
            }
        }
    }
}


#Preview {
    PatientTiles()
        .environment(PatientListModel())
}
