//
//  PatientRow.swift
//  NAMS
//
//  Created by Andreas Bauer on 11.06.23.
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
