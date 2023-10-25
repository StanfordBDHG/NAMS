//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import OrderedCollections
import OSLog
import SpeziFirestore
import SpeziViews
import SwiftUI


@MainActor
@Observable
class PatientListModel {
    static let logger = Logger(subsystem: "edu.stanford.NAMS", category: "PatientListModel")

    var patientList: [Patient]? // swiftlint:disable:this discouraged_optional_collection
    var activePatient: Patient?

    var categorizedPatients: OrderedDictionary<Character, [Patient]> = [:]

    @ObservationIgnored var patientListListener: ListenerRegistration?
    @ObservationIgnored var activePatientListener: ListenerRegistration?

    private var patientsCollection: CollectionReference {
        Firestore.firestore().collection("patients")
    }


    init() {}


    func retrieveList(viewState: Binding<ViewState>) {
        closeList()

        // for ordered queries, Firebase requires an index that is to be created manually
        patientListListener = patientsCollection
            .order(by: "name.givenName")
            .order(by: "name.familyName")
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    Self.logger.error("Failed to retrieve patient list: \(error)")
                    viewState.wrappedValue = .error(FirestoreError(error!)) // swiftlint:disable:this force_unwrapping
                    return
                }

                do {
                    let patientList = try snapshot.documents.map { document in
                        try document.data(as: Patient.self)
                    }
                    self.patientList = patientList
                    self.categorizedPatients = patientList.reduce(into: [:], { result, patient in
                        if let character = patient.firstLetter {
                            result[character, default: []].append(patient)
                        }
                    })
                } catch {
                    if error is DecodingError {
                        Self.logger.error("Failed to decode patient list: \(error)")
                        viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                    } else {
                        Self.logger.error("Unexpected error occurred while decoding patient list: \(error)")
                        viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                    }
                }
            }
    }

    func add(patient: NewPatientModel) async throws {
        let patient = Patient(from: patient)

        do {
            try await patientsCollection
                .addDocument(from: patient)
        } catch {
            Self.logger.error("Failed to add new patient information: \(error)")
            throw FirestoreError(error)
        }
    }

    func remove(patientId: String, viewState: Binding<ViewState>) async {
        if let activePatient, activePatient.id == patientId {
            removeActivePatientListener()
        }

        do {
            Self.logger.info("Deleting patient with ")
            try await patientsCollection.document(patientId).delete()
        } catch {
            viewState.wrappedValue = .error(FirestoreError(error))
        }
    }

    func loadActivePatient(for id: String, viewState: Binding<ViewState>) {
        removeActivePatientListener()

        self.activePatientListener = patientsCollection.document(id).addSnapshotListener { snapshot, error in
            guard let snapshot else {
                Self.logger.error("Failed to retrieve active patient: \(error)")
                viewState.wrappedValue = .error(FirestoreError(error!)) // swiftlint:disable:this force_unwrapping
                return
            }

            do {
                self.activePatient = try snapshot.data(as: Patient.self)
            } catch {
                if error is DecodingError {
                    Self.logger.error("Failed to decode patient list: \(error)")
                    viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                } else {
                    Self.logger.error("Unexpected error occurred while decoding patient list: \(error)")
                    viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                }
            }
        }
    }

    func closeList() {
        if let patientListListener {
            patientListListener.remove()
            self.patientListListener = nil
        }
    }

    func removeActivePatientListener() {
        if let activePatientListener {
            activePatientListener.remove()
            self.activePatientListener = nil
        }
    }
}
