//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


@MainActor
struct PatientInformationView: View {
    private let patient: Patient

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.locale)
    private var locale

    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle
    @State private var presentingDeleteConfirmation = false

    private var dateFormatStyle: Date.FormatStyle {
        .init()
        .locale(locale)
        .year(.defaultDigits)
        .month(locale.identifier == "en_US" ? .abbreviated : .defaultDigits)
        .day(.defaultDigits)
    }

    var body: some View {
        List {
            PatientInformationHeader(patient: patient)

            if patient.sex != nil || patient.birthdate != nil {
                Section("Details") {
                    if let sex = patient.sex {
                        ListRow("Sex") {
                            Text(sex.localizedStringResource)
                        }
                    }
                    if let birthdate = patient.birthdate {
                        ListRow("Birthdate") {
                            Text(verbatim: birthdate.formatted(dateFormatStyle))
                        }
                    }
                }
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
    PatientInformationView(
        patient: Patient(
            id: "1234",
            name: .init(givenName: "Andreas", familyName: "Bauer"),
            code: "AB1234",
            sex: .male,
            birthdate: .now,
            note: "These are some notes ..."
        )
    )
        .previewWith {
            PatientListModel()
        }
}
#endif
