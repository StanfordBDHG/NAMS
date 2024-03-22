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


struct SelectedPatientCard: View {
    private let patient: Patient

    private var name: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        NavigationLink {
            PatientInformationView(patient: patient)
        } label: {
            HStack {
                UserProfileView(name: patient.name)
                    .frame(height: 50)
                VStack(alignment: .leading) {
                    Text(verbatim: name)
                        .foregroundColor(.primary)
                        .bold()
                    Text("Selected Patient")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
                Spacer()
            }
        }
            .accessibilityLabel("Selected Patient: \(name)")
    }


    init(patient: Patient) {
        self.patient = patient
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        List {
            SelectedPatientCard(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer"))
            )
        }
            .listStyle(.inset)
    }
        .previewWith {
            PatientListModel()
        }
}
#endif
