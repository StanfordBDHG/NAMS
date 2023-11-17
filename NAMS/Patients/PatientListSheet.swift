//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFirestore
import SpeziViews
import SwiftUI


struct PatientListSheet: View {
    @Environment(PatientListModel.self)
    private var patientList

    @Environment(\.dismiss)
    private var dismiss

    @State private var viewState: ViewState = .idle
    @State private var showAddPatientSheet = false

    @State private var searchModel = PatientSearchModel()

    @Binding private var activePatientId: String?

    var body: some View {
        NavigationStack {
            PatientList(patients: patientList.categorizedPatients, viewState: $viewState, activePatientId: $activePatientId)
                .navigationTitle(Text("Patients", comment: "Patient List Title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Patient.self) { patient in
                    PatientInformation(patient: patient, activePatientId: $activePatientId)
                }
                .environment(searchModel)
                .sheet(isPresented: $showAddPatientSheet) {
                    AddPatientView()
                }
                .toolbar {
                    toolbar
                }
                .searchable(text: $searchModel.searchText, prompt: "Search for a patient")
                .viewStateAlert(state: $viewState)
                .onChange(of: viewState, { oldValue, newValue in
                    if case .error = oldValue,
                       case .idle = newValue {
                        dismiss() // close the view after dismissing the error
                    }
                })
                .onAppear {
                    patientList.retrieveList(viewState: $viewState)
                }
                .onDisappear {
                    patientList.closeList()
                }
        }
    }

    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: {
                dismiss()
            }) {
                Text("Close")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showAddPatientSheet = true
            }) {
                Image(systemName: "plus")
                    .accessibilityLabel("Add Patient")
            }
        }
    }


    init(activePatientId: Binding<String?>) {
        self._activePatientId = activePatientId
    }
}


#if DEBUG
#Preview {
    PatientListSheet(activePatientId: .constant(nil))
        .environment(PatientListModel())
}
#endif
