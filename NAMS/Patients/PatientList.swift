//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct PatientList: View {
    private let patients: [Patient]? // swiftlint:disable:this discouraged_optional_collection
    private let searchModel: PatientSearchModel

    var body: some View {
        if let patients {
            let searchResults = searchModel.search(in: patients)
            if searchResults.isEmpty {
                NoInformationText {
                    Text("No Patients")
                } caption: {
                    Text("Patients will appear here,\nonce they are added.")
                }
            } else {
                List {
                    ForEach(searchResults) { patient in
                        NavigationLink(value: patient) {
                            // TODO we want to select the global patient!
                            PatientRow(patient: patient)
                        }
                    }
                        // TODO we need a model!
                        .onDelete { indexSet in
                            // TODO delete!
                            print("Deleted \(indexSet.sorted())")
                        }
                }
            }
        } else {
            ProgressView()
        }
    }


    init(patients: [Patient]?, searchModel: PatientSearchModel) {
        self.patients = patients
        self.searchModel = searchModel
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PatientList(patients: [
            Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")),
            Patient(id: "2", name: .init(givenName: "Paul", familyName: "Schmiedmayer")),
            Patient(id: "3", name: .init(givenName: "Leland", familyName: "Stanford"))
        ], searchModel: PatientSearchModel())
            .navigationDestination(for: Patient.self) { patient in // TODO use a destination view in the link instead?
                PatientInformation(patient: patient, activePatientId: .constant(nil))
            }
    }
}
#Preview {
    PatientList(patients: [], searchModel: PatientSearchModel())
}

#Preview {
    PatientList(patients: nil, searchModel: PatientSearchModel())
}
#endif
