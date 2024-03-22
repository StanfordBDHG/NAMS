//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SpeziValidation
import SpeziViews
import SwiftUI


struct GridValidationStateFooter: View {
    private var results: [FailedValidationResult]

    var body: some View {
        if !results.isEmpty { // otherwise we have some weird layout issues in Grids
            HStack {
                ValidationResultsView(results: results)
                Spacer()
            }
        }
    }

    init(_ results: [FailedValidationResult]) {
        self.results = results
    }
}


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

    @ValidationState private var validation
    @ValidationState private var givenNameValidation
    @ValidationState private var familyNameValidation

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: 1800, month: 1, day: 1)
        let endDate = Date.now

        guard let startDate = calendar.date(from: startDateComponents) else {
            fatalError("Could not translate \(startDateComponents) to a valid date.")
        }

        return startDate...endDate
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Name") {
                        nameFields
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.words)
                    }

                    Section {
                        VerifiableTextField("required", text: $newPatient.code)
                            .validate(input: newPatient.code, rules: .nonEmpty, .patientCodeMaxLength)
                    } header: {
                        Text("Patient Code")
                    } footer: {
                        Text("An hospital administered patient identifier.")
                    }

                    detailsSection

                    Section("Notes") {
                        TextField("add notes ...", text: $newPatient.notes, axis: .vertical)
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
            .receiveValidation(in: $validation)
    }

    @ViewBuilder var nameFields: some View {
        Grid(horizontalSpacing: 20) {
            NameFieldRow(.init("First", comment: "First Name Field Description"), name: $newPatient.name, for: \.givenName) {
                Text("enter first name")
            }
                .validate(input: newPatient.name.givenName ?? "", rules: .nonEmpty)
                .receiveValidation(in: $givenNameValidation)
                .focusOnTap()

            GridValidationStateFooter(givenNameValidation.allDisplayedValidationResults)

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow(.init("Last", comment: "Last Name Field Description"), name: $newPatient.name, for: \.familyName) {
                Text("enter last name")
            }
                .validate(input: newPatient.name.familyName ?? "", rules: .nonEmpty)
                .receiveValidation(in: $familyNameValidation)
                .focusOnTap()

            GridValidationStateFooter(familyNameValidation.allDisplayedValidationResults)
        }
    }

    @ViewBuilder var detailsSection: some View {
        Section("Details") {
            Picker(
                selection: $newPatient.sex,
                content: {
                    ForEach(Patient.Sex.allCases) { sex in
                        Text(sex.localizedStringResource)
                            .tag(sex)
                    }
                }, label: {
                    Text("Sex")
                }
            )
            DatePicker(
                selection: $newPatient.birthdate,
                in: dateRange,
                displayedComponents: .date
            ) {
                Text("Birthdate")
            }
        }
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
                .disabled(!validation.allInputValid)
        }
    }


    init() {}
}


extension ValidationRule {
    fileprivate static var patientCodeMaxLength: ValidationRule {
        ValidationRule(rule: { input in
            input.count <= 64
        }, message: "The patient code cannot be longer than 64 characters.")
    }
}


#if DEBUG
#Preview {
    AddPatientView()
        .previewWith {
            PatientListModel()
        }
}
#endif
