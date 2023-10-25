//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CurrentPatientLabel: View {
    @Environment(PatientListModel.self)
    private var patientList

    @Binding private var activePatientId: String?

    var body: some View {
        HStack {
            if let patient = patientList.activePatient, activePatientId != nil {
                Text(verbatim: patient.name.formatted(.name(style: .medium)))
                    .fontWeight(.medium)
            } else {
                Text("Select Patient", comment: "Principal Select Patient Button placeholder")
                    .italic()
            }

            Image(systemName: "chevron.down.circle.fill")
                .foregroundColor(.secondary)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
            .foregroundColor(.primary)
    }


    init(activePatient: Binding<String?>) {
        self._activePatientId = activePatient
    }
}


#if DEBUG
#Preview {
    Button(action: {}) {
        CurrentPatientLabel(activePatient: .constant(nil))
            .environment(PatientListModel())
    }
}
#endif
