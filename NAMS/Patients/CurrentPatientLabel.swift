//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CurrentPatientLabel: View {
    @Binding private var activePatientId: String? // TODO no binding needed right?
    private let patientList: PatientListModel

    var body: some View {
        HStack {
            if let patient = patientList.activePatient {
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
            .onAppear(perform: handlePatientIdChange)
            .onChange(of: activePatientId, handlePatientIdChange)
            .onDisappear {
                patientList.removeActivePatientListener()
            }
        /*
         HStack {
         Text("Andreas Bauer")

         Image(systemName: "chevron.down.circle.fill")
         .symbolRenderingMode(.hierarchical)
         .accessibilityHidden(true)
         // TODO visuals!
         }
         .accessibilityLabel("Selected Patient: Andreas Bauer")
         */
    }


    init(activePatient: Binding<String?>, patientList: PatientListModel) {
        self._activePatientId = activePatient
        self.patientList = patientList
    }


    func handlePatientIdChange() {
        if let activePatientId {
            do {
                try patientList.loadActivePatient(for: activePatientId)
            } catch {
                print("ASDDF \(error)") // TODO error handling!
            }
        }
    }
}


// TODO previews
#Preview {
    Button(action: {}) {
        CurrentPatientLabel(activePatient: .constant(nil), patientList: PatientListModel())
    }
}
