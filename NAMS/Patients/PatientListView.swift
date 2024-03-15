//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


struct PatientListView: View {
    private let patients: OrderedDictionary<Character, [Patient]>?

    @Environment(PatientListModel.self)
    private var patientList
    @Environment(PatientSearchModel.self)
    private var searchModel

    @Binding private var navigationPath: NavigationPath
    @Binding private var viewState: ViewState

    private var displayedCount: Int {
        patients?.reduce(into: 0, { result, element in
            result += element.value.count
        }) ?? 0
    }

    var body: some View {
        if let patients {
            let searchResults = searchModel.search(in: patients)

            if searchResults.isEmpty {
                ContentUnavailableView {
                    Label("No Patients", systemImage: "person.3.sequence.fill")
                } description: {
                    Text("Patients will appear here,\nonce they are added.")
                }
            } else {
                List {
                    if let selectedPatient = patientList.activePatient, patientList.activePatientId != nil {
                        Section {
                            SelectedPatientCard(patient: selectedPatient)
                        }
                    }

                    if displayedCount < 6 {
                        patientRows(searchResults.reduce(into: [], { result, element in
                            result.append(contentsOf: element.value)
                        }))
                    } else {
                        ForEach(searchResults.elements, id: \.key) { letter, patients in
                            if patients.isEmpty {
                                EmptyView()
                            } else {
                                Section {
                                    patientRows(patients)
                                } header: {
                                    Text(verbatim: "\(letter)")
                                }
                            }
                        }
                    }
                }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            EditButton()
                        }
                    }
                    .listStyle(.inset)
            }
        } else {
            ProgressView()
        }
    }


    init(
        patients: OrderedDictionary<Character, [Patient]>?,
        path: Binding<NavigationPath>,
        viewState: Binding<ViewState>
    ) {
        self.patients = patients
        self._navigationPath = path
        self._viewState = viewState
    }


    @MainActor
    @ViewBuilder
    func patientRows(_ patients: [Patient]) -> some View {
        ForEach(patients) { patient in
            PatientRow(patient: patient, path: $navigationPath)
        }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        let patient = patients[index]
                        guard let patientId = patient.id else {
                            continue // this is a problem!
                        }


                        await patientList.remove(patientId: patientId, viewState: $viewState)
                    }
                }
            }
    }
}


#if DEBUG
#Preview {
    NavigationStackWithPath { path in
        PatientListView(
            patients: [
                "A": [Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer"))],
                "E": [Patient(id: "6", name: .init(givenName: "Erik", familyName: "Gross"))],
                "J": [Patient(id: "4", name: .init(givenName: "John", familyName: "Smith"))],
                "L": [
                    Patient(id: "3", name: .init(givenName: "Leland", familyName: "Stanford")),
                    Patient(id: "5", name: .init(givenName: "Lola", familyName: "Woodard"))
                ],
                "P": [Patient(id: "2", name: .init(givenName: "Paul", familyName: "Schmiedmayer"))]
            ],
            path: path,
            viewState: .constant(.idle)
        )
            .navigationDestination(for: Patient.self) { patient in
                PatientInformationView(patient: patient)
            }
            .environment(PatientSearchModel())
    }
        .previewWith {
            PatientListModel()
        }
}
#Preview {
    NavigationStackWithPath { path in
        PatientListView(
            patients: [
                "A": [Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer"))],
                "L": [Patient(id: "3", name: .init(givenName: "Leland", familyName: "Stanford"))],
                "P": [Patient(id: "2", name: .init(givenName: "Paul", familyName: "Schmiedmayer"))]
            ],
            path: path,
            viewState: .constant(.idle)
        )
            .navigationDestination(for: Patient.self) { patient in
                PatientInformationView(patient: patient)
            }
            .environment(PatientSearchModel())
    }
        .previewWith {
            PatientListModel()
        }
}
#Preview {
    NavigationStackWithPath { path in
        PatientListView(patients: [:], path: path, viewState: .constant(.idle))
            .environment(PatientSearchModel())
    }
        .previewWith {
            PatientListModel()
        }
}

#Preview {
    NavigationStackWithPath { path in
        PatientListView(patients: nil, path: path, viewState: .constant(.idle))
            .environment(PatientSearchModel())
    }
        .previewWith {
            PatientListModel()
        }
}
#endif
