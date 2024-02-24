//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SpeziViews
import SwiftUI


@MainActor
struct PatientInformation: View {
    private let patient: Patient

    @Environment(\.dismiss)
    private var dismiss
    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle
    @State private var presentingDeleteConfirmation = false

    private var name: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        List {
            VStack {
                UserProfileView(name: patient.name)
                    .frame(height: 60)
                Text(verbatim: name)
                    .foregroundColor(.primary)
                    .font(.title)
                    .fontWeight(.semibold)
            }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .accessibilityRepresentation {
                    Text(verbatim: name)
                        .accessibilityAddTraits(.isHeader)
                }

            if let note = patient.note {
                Section("Notes") {
                    Text(verbatim: note)
                        .font(.callout)
                        .lineLimit(3...7)
                }
            }

            selectButton

            deleteButton
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle("Patient Overview")
    }

    @ViewBuilder private var selectButton: some View {
        if !patient.isSelectedPatient(active: patientList.activePatientId) {
            Section {
                Button(action: {
                    patientList.activePatientId = patient.id
                    dismiss()
                }) {
                    Text("Select Patient")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder private var deleteButton: some View {
        Section {
            AsyncButton(role: .destructive, state: $viewState, action: {
                presentingDeleteConfirmation = true
            }) {
                Text("Delete Patient")
                    .frame(maxWidth: .infinity)
            }
                .confirmationDialog(
                    "Are you sure you want to delete this patient?",
                    isPresented: $presentingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    AsyncButton(role: .destructive, state: $viewState, action: {
                        guard let patientId = patient.id else {
                            return
                        }

                        await patientList.remove(patientId: patientId, viewState: $viewState)
                        dismiss()
                    }) {
                        Text("Delete")
                    }

                    Button(role: .cancel, action: {}) {
                        Text("Cancel")
                    }
                }
        }
    }


    init(patient: Patient) {
        self.patient = patient
    }
}


#if DEBUG
#Preview {
    PatientInformation(
        patient: Patient(id: "1234", name: .init(givenName: "Andreas", familyName: "Bauer"), note: "These are some notes ...")
    )
        .environment(PatientListModel())
}
#endif
