//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziDevicesUI
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


struct PatientRow: View {
    private let patient: Patient

    @Environment(PatientListModel.self)
    private var patientList

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.editMode)
    private var editMode

    @Binding private var path: NavigationPath

    private var patientName: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        HStack {
            selectPatientButton
            detailsButton
        }
            .accessibilityRepresentation { @MainActor in
                HStack { @MainActor in
                    Button(action: selectPatientAction) {
                        Text(verbatim: patientName)
                        Spacer()
                        if patient.isSelectedPatient(active: patientList.activePatientId) {
                            Text("Selected", comment: "Selected Patient")
                        }
                    }
#if TEST
                    detailsButton
                        .accessibilityLabel("\(patientName), Patient Details")
#endif
                }
#if !TEST
                    .accessibilityAction(named: "Patient Details", detailsButtonAction)
#endif
            }
    }

    @ViewBuilder @MainActor private var selectPatientButton: some View {
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
                    && patient.isSelectedPatient(active: patientList.activePatientId) {
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


    init(patient: Patient, path: Binding<NavigationPath>) {
        self.patient = patient
        self._path = path
    }


    @MainActor
    func selectPatientAction() {
        if patient.isSelectedPatient(active: patientList.activePatientId) {
            patientList.activePatientId = nil
        } else {
            patientList.activePatientId = patient.id
        }

        dismiss()
    }

    func detailsButtonAction() {
        path.append(patient)
    }
}


#if DEBUG
#Preview {
    NavigationStackWithPath { path in
        List {
            PatientRow(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer"), code: "AB123", sex: .male, birthdate: .now),
                path: path
            )
        }
            .navigationDestination(for: Patient.self) { patient in
                PatientInformationView(patient: patient)
            }
    }
        .previewWith {
            PatientListModel()
        }
}

#Preview {
    NavigationStackWithPath { path in
        List {
            PatientRow(
                patient: Patient(id: "1", name: .init(givenName: "Andreas", familyName: "Bauer")),
                path: path
            )
        }
            .navigationDestination(for: Patient.self) { patient in
                PatientInformationView(patient: patient)
            }
    }
        .previewWith {
            PatientListModel()
        }
}
#endif
