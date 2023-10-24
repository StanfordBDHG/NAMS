//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct PatientInformation: View {
    private let patient: Patient

    @Binding private var activePatientId: String?

    var body: some View {
        List {
            HStack {
                UserProfileView(name: patient.name)
                    .frame(height: 30)
                Group {
                    Text(verbatim: patient.name.formatted(.name(style: .long)))
                    Spacer()
                }
                .foregroundColor(.primary)
            }

            Button(action: {
                activePatientId = patient.id
            }) {
                Text("Set Active")
            }
        }
    }


    init(patient: Patient, activePatientId: Binding<String?>) {
        self.patient = patient
        self._activePatientId = activePatientId
    }
}

#if DEBUG
#Preview {
    PatientInformation(
        patient: Patient(id: "1234", name: .init(givenName: "Andreas", familyName: "Bauer")),
        activePatientId: .constant(nil)
    )
}
#endif
