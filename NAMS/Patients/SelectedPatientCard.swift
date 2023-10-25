//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SelectedPatientCard: View {
    private let patient: Patient

    var body: some View {
        HStack {
            UserProfileView(name: patient.name)
                .frame(height: 50)
            VStack(alignment: .leading) {
                Text(verbatim: patient.name.formatted(.name(style: .long)))
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


    init(patient: Patient) {
        self.patient = patient
    }
}

#Preview {
    List {
        SelectedPatientCard(patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")))
    }
        .listStyle(.inset)
}
