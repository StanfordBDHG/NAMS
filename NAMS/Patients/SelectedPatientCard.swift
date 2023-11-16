//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SpeziViews
import SwiftUI


struct SelectedPatientCard: View {
    private let patient: Patient

    @Binding private var activePatientId: String?

    private var name: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        NavigationLink {
            PatientInformation(patient: patient, activePatientId: $activePatientId)
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


    init(patient: Patient, activePatientId: Binding<String?>) {
        self.patient = patient
        self._activePatientId = activePatientId
    }
}

#Preview {
    NavigationStack {
        List {
            SelectedPatientCard(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")),
                activePatientId: .constant("1")
            )
        }
            .listStyle(.inset)
    }
}
