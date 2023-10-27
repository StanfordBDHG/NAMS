//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct MeasurementTask: PatientTask {
    let id: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let completedDescription: LocalizedStringResource

    let tileType: TileType = .recording
    let expectedCompletionMinutes: String

    let requiresConnectedDevice: Bool
}


extension MeasurementTask {
    static let all: [MeasurementTask] = [.eegMeasurement]

    static var eegMeasurement: MeasurementTask = {
        MeasurementTask(
            id: "eeg-recording",
            title: "EEG Recording",
            description: .init("Start a EEG Recording for the current patient ...", comment: "EEG Tile description"),
            completedDescription: "Brain activity was collected for this patient.",
            expectedCompletionMinutes: "5",
            requiresConnectedDevice: true
        )
    }()
}
