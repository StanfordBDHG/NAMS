//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


@MainActor
struct PatientInformation: View {
    private let patient: Patient

    @Environment(\.dismiss)
    private var dismiss
    @Environment(PatientListModel.self)
    private var patientList

    @State private var viewState: ViewState = .idle

    @Binding private var activePatientId: String?

    private var name: String {
        patient.name.formatted(.name(style: .long))
    }

    var body: some View {
        List {
            VStack {
                UserProfileView(name: patient.name)
                    .frame(height: 60)
                Text(verbatim: name)
                    .foregroundColor(.primary)
                    .font(.title)
                    .fontWeight(.semibold)
            }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .accessibilityRepresentation {
                    Text(verbatim: name)
                }

            if let note = patient.note {
                Section("Notes") {
                    Text(verbatim: note)
                        .font(.callout)
                        .lineLimit(3...7)
                }
            }

            selectButton

            deleteButton
        }
            .viewStateAlert(state: $viewState)
    }

    @ViewBuilder private var selectButton: some View {
        if !patient.isSelectedPatient(active: activePatientId) {
            Section {
                Button(action: {
                    activePatientId = patient.id
                    dismiss()
                }) {
                    Text("Select Patient")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder private var deleteButton: some View {
        Section {
            AsyncButton(role: .destructive, state: $viewState, action: {
                guard let patientId = patient.id else {
                    return
                }

                await patientList.remove(patientId: patientId, viewState: $viewState)
                dismiss()
            }) {
                Text("Delete Patient Information")
                    .frame(maxWidth: .infinity)
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
        patient: Patient(id: "1234", name: .init(givenName: "Andreas", familyName: "Bauer"), note: "These are some notes ..."),
        activePatientId: .constant(nil)
    )
        .environment(PatientListModel())
}
#endif
