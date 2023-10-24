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
struct AddPatientView: View {
    enum FocusedField: Hashable {
        case givenName
        case lastName
        case notes
    }

    @Environment(\.dismiss)
    private var dismiss

    private let patientList: PatientListModel
    @State private var newPatient = NewPatientModel()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedField: FocusedField?

    @State private var showCancellationConfirmation = false


    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Name") {
                        NameFields(
                            name: $newPatient.name,
                            givenNameFieldIdentifier: .givenName,
                            familyNameFieldIdentifier: .lastName,
                            focusedState: _focusedField
                        )
                    }

                    Section("Notes") {
                        TextField("Add Notes", text: $newPatient.notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                    .autocorrectionDisabled(true)
            }
                .navigationTitle(Text("Add Patient", comment: "Add Patient Title"))
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog("Are you sure you want to discard this new patient?", isPresented: $showCancellationConfirmation, actions: {
                    Button("Discard Changes", role: .destructive, action: {
                        dismiss()
                    })
                    Button("Keep Editing", role: .cancel, action: {})
                })
                .toolbar {
                    toolbar
                }
                .interactiveDismissDisabled(newPatient.shouldAskForCancelConfirmation)
        }
            .viewStateAlert(state: $viewState)
    }

    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel, action: {
                if newPatient.shouldAskForCancelConfirmation {
                    showCancellationConfirmation = true
                } else {
                    dismiss()
                }
            }) {
                Text("Cancel")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            AsyncButton(state: $viewState, action: {
                try await patientList.add(patient: newPatient)
                // TODO refresh the patient model in the view behind the sheet!
                dismiss()
            }) {
                Text("Done")
            }
        }
    }


    init(patientList: PatientListModel) {
        self.patientList = patientList
    }
}


#if DEBUG
#Preview {
    AddPatientView(patientList: PatientListModel())
}
#endif
