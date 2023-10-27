//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@MainActor
struct MeasurementTile: View {
    private let task: MeasurementTask
    private let deviceConnected: Bool

    @Environment(PatientListModel.self)
    private var patientList

    @Binding private var presentingEEGRecording: Bool

    private var completed: Bool {
        patientList.completedTaskIds?.contains(task.id) == true
    }

    var body: some View {
        if completed {
            CompletedTile {
                Text(task.title)
            } description: {
                Text(task.completedDescription)
            }
        } else {
            SimpleTile(alignment: .center) {
                Image(systemName: "brain.fill")
                    .foregroundColor(.pink)
                    .font(.custom("EEG Icon", size: 50, relativeTo: .title))
                    .accessibilityHidden(true)
                Text(task.title)
                    .font(.title)
                    .fontWeight(.semibold)
                Text("\(task.expectedCompletionMinutes) min")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } footer: {
                tileDescription
            }
        }
    }

    @ViewBuilder private var tileDescription: some View {
        Text(task.description)
            .multilineTextAlignment(.center)
            .font(.subheadline)
            .padding(.top)

        if task.requiresConnectedDevice && !deviceConnected {
            let label = LocalizedStringResource("No EEG Headband connected ...", comment: "EEG Tile no headband warning")

            (Text("\(Image(systemName: "exclamationmark.triangle.fill")) ")
             + Text(label))
                .foregroundColor(.secondary)
                .symbolRenderingMode(.multicolor)
                .font(.footnote)
                .padding(.top, 4)
                .padding([.leading, .trailing])
                .accessibilityLabel(Text(label))
        }

        Button(action: {
            presentingEEGRecording = true
        }) {
            Text("Start \(task.tileType.localizedStringResource)")
                .frame(maxWidth: .infinity, minHeight: 30)
        }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            .tint(.pink)
            .disabled(task.requiresConnectedDevice && !deviceConnected)
    }


    init(task: MeasurementTask, presentingEEGRecording: Binding<Bool>, deviceConnected: Bool) {
        self.task = task
        self._presentingEEGRecording = presentingEEGRecording
        self.deviceConnected = deviceConnected
    }
}


#if DEBUG
#Preview {
    List {
        MeasurementTile(task: .eegMeasurement, presentingEEGRecording: .constant(false), deviceConnected: true)
    }
}

#Preview {
    List {
        MeasurementTile(task: .eegMeasurement, presentingEEGRecording: .constant(false), deviceConnected: false)
    }
}
#endif
