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
    private let patientList: PatientListModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var viewState: ViewState = .idle
    @State private var showAddPatientSheet = false

    @State private var searchModel = PatientSearchModel()

    @Binding private var activePatientId: String?

    var body: some View {
        NavigationStack {
            PatientList(patients: patientList.patientList, searchModel: searchModel)
                .navigationTitle(Text("Patients", comment: "Patient List Title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Patient.self) { patient in
                    PatientInformation(patient: patient, activePatientId: $activePatientId)
                }
                .sheet(isPresented: $showAddPatientSheet) {
                    AddPatientView(patientList: patientList)
                }
                .toolbar {
                    toolbar
                }
                .searchable(text: $searchModel.searchText, prompt: "Search for a patient")
                .onAppear {
                    do {
                        try patientList.retrieveList()
                    } catch {
                        // TODO handle errors here?
                    }
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
        ToolbarItem(placement: .primaryAction) {
            EditButton()
        }
    }


    init(patientList: PatientListModel, activePatientId: Binding<String?>) {
        self.patientList = patientList
        self._activePatientId = activePatientId
    }
}

#if DEBUG
#Preview {
    PatientListSheet(patientList: PatientListModel(), activePatientId: .constant(nil))
}
#endif
