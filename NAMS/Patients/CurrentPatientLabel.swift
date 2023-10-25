//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CurrentPatientLabel: View {
    @Binding private var activePatientId: String?
    private let patientList: PatientListModel

    @State private var viewState: ViewState = .idle

    var body: some View {
        HStack {
            if let patient = patientList.activePatient, activePatientId != nil {
                Text(verbatim: patient.name.formatted(.name(style: .medium)))
                    .fontWeight(.medium)
            } else {
                Text("Select Patient", comment: "Principal Select Patient Button placeholder")
                    .italic()
            }

            Image(systemName: "chevron.down.circle.fill")
                .foregroundColor(.secondary)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
            .foregroundColor(.primary)
            .viewStateAlert(state: $viewState)
            .onAppear(perform: handlePatientIdChange)
            .onDisappear {
                patientList.removeActivePatientListener()
            }
            .onChange(of: activePatientId, handlePatientIdChange)
            .onChange(of: viewState) { oldValue, newValue in
                if case .error = oldValue,
                   case .idle = newValue {
                    activePatientId = nil // reset the current patient on an error
                }
            }
    }


    init(activePatient: Binding<String?>, patientList: PatientListModel) {
        self._activePatientId = activePatient
        self.patientList = patientList
    }


    @MainActor
    func handlePatientIdChange() {
        if let activePatientId {
            patientList.loadActivePatient(for: activePatientId, viewState: $viewState)
        } else {
            patientList.removeActivePatientListener()
        }
    }
}


#if DEBUG
#Preview {
    Button(action: {}) {
        CurrentPatientLabel(activePatient: .constant(nil), patientList: PatientListModel())
    }
}
#endif
