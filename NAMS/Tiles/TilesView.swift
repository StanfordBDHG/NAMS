//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth
import SpeziQuestionnaire
import SpeziViews
import SwiftUI


@MainActor
struct TilesView: View {
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator
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
                            deviceConnected: deviceCoordinator.isConnected
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
                        EEGRecording()
                    }
                }
        }
    }


    init() {}


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
    return TilesView()
        .environment(patientList)
        .previewWith {
            EEGRecordings()
            DeviceCoordinator(mock: MockDevice(name: "Mock Device 1", state: .connected))
        }
}

#Preview {
    let patientList = PatientListModel()
    patientList.completedTasks = []
    return TilesView()
        .environment(patientList)
        .previewWith {
            EEGRecordings()
            DeviceCoordinator()
        }
}

#Preview {
    TilesView()
        .environment(PatientListModel())
        .previewWith {
            EEGRecordings()
            DeviceCoordinator()
        }
}
#endif
