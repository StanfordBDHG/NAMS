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
struct TilesView: View {
    private let eegModel: EEGViewModel

    @Environment(BiopotDevice.self)
    private var biopot
    @Environment(PatientListModel.self)
    private var patientList


    @State private var viewState: ViewState = .idle

    @State private var presentingQuestionnaire: Questionnaire?
    @State private var presentingEEGRecording = false

    private var questionnaires: [ScreeningTask] {
        taskList(ScreeningTask.all)
    }

    private var measurements: [MeasurementTask] {
        taskList(MeasurementTask.all)
    }

    var body: some View {
        if patientList.completedTasks == nil {
            ProgressView()
        } else {
            List {
                Section("Measurements") {
                    ForEach(measurements) { measurement in
                        MeasurementTile(
                            task: measurement,
                            presentingEEGRecording: $presentingEEGRecording,
                            deviceConnected: eegModel.activeDevice != nil || biopot.connected
                        )
                    }
                }

                Section("Screening") {
                    ForEach(questionnaires) { questionnaire in
                        ScreeningTile(task: questionnaire, presentingItem: $presentingQuestionnaire)
                    }
                }
            }
                .viewStateAlert(state: $viewState)
                .sheet(item: $presentingQuestionnaire) { questionnaire in
                    QuestionnaireView(questionnaire: questionnaire) { result in
                        presentingQuestionnaire = nil

                        guard case let .completed(response) = result else {
                            return
                        }

                        do {
                            try await patientList.add(response: response)
                        } catch {
                            viewState = .error(AnyLocalizedError(error: error))
                        }
                    }
                        .interactiveDismissDisabled()
                }
                .sheet(isPresented: $presentingEEGRecording) {
                    NavigationStack {
                        EEGRecording(eegModel: eegModel)
                    }
                }
        }
    }


    init(eegModel: EEGViewModel) {
        self.eegModel = eegModel
    }


    private func taskList<T: PatientTask>(_ tasks: [T]) -> [T] {
        guard let completedList = patientList.completedTaskIds else {
            return tasks
        }

        return tasks.sorted { lhs, rhs in
            !completedList.contains(lhs.id) && completedList.contains(rhs.id)
        }
    }
}


#if DEBUG
#Preview {
    let patientList = PatientListModel()
    patientList.completedTasks = []
    return TilesView(eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
        .environment(patientList)
        .biopotPreviewSetup()
}

#Preview {
    TilesView(eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
        .environment(PatientListModel())
        .biopotPreviewSetup()
}
#endif
