//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


struct PatientInformationHeader: View {
    private let patient: Patient

    private var name: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        VStack {
            UserProfileView(name: patient.name)
                .frame(height: 60)
            Text(verbatim: name)
                .foregroundColor(.primary)
                .font(.title)
                .fontWeight(.semibold)

            if let code = patient.code {
                Text(verbatim: code)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .accessibilityRepresentation {
            Text(verbatim: name)
                .accessibilityAddTraits(.isHeader)
        }
    }


    init(patient: Patient) {
        self.patient = patient
    }
}


#if DEBUG
#Preview {
    PatientInformationHeader(
        patient: Patient(
            id: "1234",
            name: .init(givenName: "Andreas", familyName: "Bauer"),
            code: "AB1234",
            sex: .male,
            birthdate: .now,
            note: "These are some notes ..."
        )
    )
}
#endif
