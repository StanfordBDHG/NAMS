//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

struct PatientRow: View {
    var patient: Patient

    var body: some View {
        HStack {
            UserProfileView(name: patient.name)
                .frame(height: 30)
            Text(verbatim: patient.name.formatted(.name(style: .long)))
            Spacer()
        }
    }
}

#if DEBUG
struct PatientRow_Previews: PreviewProvider {
    static var previews: some View {
        PatientRow(patient: Patient(id: "1234", name: .init(givenName: "Andreas", familyName: "Bauer")))
    }
}
#endif
