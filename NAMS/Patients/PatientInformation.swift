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
    var patient: Patient

    var body: some View {
        let name = PersonNameComponents(givenName: patient.firstName, familyName: patient.lastName)

        HStack {
            UserProfileView(name: name)
                .frame(height: 30)
            Group {
                Text(name.formatted(.name(style: .medium)))
                Spacer()
            }
            .foregroundColor(.primary)
        }
    }
}

#if DEBUG
struct PatientInformation_Previews: PreviewProvider {
    static var previews: some View {
        PatientInformation(patient: Patient(id: "1234", firstName: "Andreas", lastName: "Bauer"))
    }
}
#endif
