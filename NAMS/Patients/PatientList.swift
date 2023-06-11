//
//  PatientList.swift
//  NAMS
//
//  Created by Andreas Bauer on 11.06.23.
//

import SwiftUI

enum SearchToken: String, Identifiable, Hashable, CaseIterable {
    case patientId
    case name

    var id: String {
        rawValue
    }

    @ViewBuilder
    var tokenLabel: some View {
        switch self {
        case .patientId:
            Label("Patient Id", systemImage: "grid.circle.fill")
        case .name:
            Label("Name", systemImage: "person.text.rectangle")
        }
    }
}

struct PatientList: View {
    // TODO where to get the data from?
    @State var patients: [Patient] = [
        Patient(id: "1", firstName: "Andreas", lastName: "Bauer"),
        Patient(id: "2", firstName: "Paul", lastName: "Schmiedmayer"),
        Patient(id: "3", firstName: "Leland", lastName: "Stanford")
    ]

    @Environment(\.dismiss)
    var dismiss

    // TODO view model
    @State
    private var searchText: String = ""
    @State
    private var searchTokens: [SearchToken] = []
    @State
    private var suggestedTokens: [SearchToken] = SearchToken.allCases
    @State
    private var showAddPatientSheet = false
    // @State
    // private var searchScope: SearchScope = SearchScope.firstname

    var searchResults: [Patient] {
        // TODO improve search!
        if searchText.isEmpty {
            return patients
        } else {
            return patients.filter { patient in
                patient.firstName.contains(searchText)
                    || patient.lastName.contains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults) { patient in
                    NavigationLink(value: patient) {
                        // TODO we want to select the global patient!
                        PatientRow(patient: patient)
                    }
                }
                    .onDelete { indexSet in
                        print("Deleted \(indexSet.sorted())")
                    }
            }
                .navigationTitle("Patients")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Patient.self) { patient in
                    PatientInformation(patient: patient)
                }
                .sheet(isPresented: $showAddPatientSheet) {
                    AddPatientView()
                }
                .toolbar {
                    toolbar
                }
                .searchable(text: $searchText, prompt: "Search for a patient")
            /*
            .searchable(text: $searchText, tokens: $searchTokens, suggestedTokens: $suggestedTokens, prompt: "Search for a patient") { token in
                token.tokenLabel
            }
             */
            /*.searchScopes($searchScope, activation: .automatic) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue.capitalized)
                }
            }*/
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
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
            }
        }
        ToolbarItem(placement: .primaryAction) {
            EditButton()
        }
    }
}

#if DEBUG
struct PatientList_Previews: PreviewProvider {
    static var previews: some View {
        PatientList(patients: [
            Patient(id: "1", firstName: "Andreas", lastName: "Bauer"),
            Patient(id: "2", firstName: "Paul", lastName: "Schmiedmayer"),
            Patient(id: "3", firstName: "Leland", lastName: "Stanford")
        ])
    }
}
#endif
