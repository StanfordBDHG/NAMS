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

    @Environment(PatientListModel.self)
    private var patientList

    @State private var newPatient = NewPatientModel()
    @State private var viewState: ViewState = .idle
    @State private var showCancellationConfirmation = false

    @FocusState private var focusedField: FocusedField?


    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Name") {
                        nameFields
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.words)
                    }

                    Section("Notes") {
                        TextField("Add Notes", text: $newPatient.notes, axis: .vertical)
                            .lineLimit(3...6)
                            .textInputAutocapitalization(.sentences)
                    }
                }
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

    @ViewBuilder var nameFields: some View {
        NameFields(
            name: $newPatient.name,
            givenNameField: .init(
                title: .init("First", comment: "First Name Field Description"),
                placeholder: "enter first name"
            ),
            givenNameFieldIdentifier: .givenName,
            familyNameField: .init(
                title: .init("Last", comment: "Last Name Field Description"),
                placeholder: "enter last name"
            ),
            familyNameFieldIdentifier: .lastName,
            focusedState: $focusedField
        )
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
                dismiss()
            }) {
                Text("Done")
            }
        }
    }


    init() {}
}


#if DEBUG
#Preview {
    AddPatientView()
        .environment(PatientListModel())
}
#endif
