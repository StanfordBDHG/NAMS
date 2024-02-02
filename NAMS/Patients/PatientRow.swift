//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


struct PatientRow: View {
    private let patient: Patient

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.editMode)
    private var editMode

    @State private var showPatientDetails = false
    @Binding private var activePatientId: String?

    private var patientName: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        HStack {
            selectPatientButton
            detailsButton
        }
            .navigationDestination(isPresented: $showPatientDetails) {
                PatientInformation(patient: patient, activePatientId: $activePatientId)
            }
            .accessibilityRepresentation {
                Button(action: selectPatientAction) {
                    Text(verbatim: patientName)
                    if patient.isSelectedPatient(active: activePatientId) {
                        Text("Selected", comment: "Selected Patient")
                    }
                }
#if !TEST
                .accessibilityAction(named: "Patient Details", detailsButtonAction)
#else
                // accessibility actions cannot be unit tested
                .frame(maxWidth: .infinity)
#endif

#if TEST
                detailsButton
                    .accessibilityLabel("\(patientName), Patient Details")
#endif
            }
    }

    @ViewBuilder private var selectPatientButton: some View {
        Button(action: selectPatientAction) {
            ListRow {
                HStack {
                    UserProfileView(name: patient.name)
                        .frame(height: 30)
                    Text(verbatim: patientName)
                        .foregroundColor(.primary)
                }
            } content: {
                if editMode?.wrappedValue.isEditing != true
                    && patient.isSelectedPatient(active: activePatientId) {
                    Text("Selected", comment: "Selected Patient")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder private var detailsButton: some View {
        Button("Patient Details", systemImage: "info.circle", action: detailsButtonAction)
            .labelStyle(.iconOnly)
            .font(.title3)
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
    }


    init(patient: Patient, activePatientId: Binding<String?>) {
        self.patient = patient
        self._activePatientId = activePatientId
    }


    func selectPatientAction() {
        if patient.isSelectedPatient(active: activePatientId) {
            activePatientId = nil
        } else {
            activePatientId = patient.id
        }

        dismiss()
    }

    func detailsButtonAction() {
        showPatientDetails = true
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        List {
            PatientRow(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")),
                activePatientId: .constant(nil)
            )
        }
    }
}

#Preview {
    NavigationStack {
        List {
            PatientRow(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")),
                activePatientId: .constant("1")
            )
        }
    }
}
#endif
