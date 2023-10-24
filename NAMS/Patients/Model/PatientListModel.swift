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
import Observation
import SpeziFirestore


@Observable
class PatientListModel {
    var patientList: [Patient]? // swiftlint:disable:this discouraged_optional_collection
    var activePatient: Patient?

    @ObservationIgnored var patientListListener: ListenerRegistration?
    @ObservationIgnored var activePatientListener: ListenerRegistration?

    private var patientsCollection: CollectionReference {
        get throws {
            guard let user = Auth.auth().currentUser else { // TODO rewrite!
                throw NAMSStandard.TemplateApplicationStandardError.userNotAuthenticatedYet
            }

            return Firestore.firestore().collection("patients")
        }
    }

    init() {}


    func retrieveList() throws {
        closeList()
        // TODO verify app background1

        // TODO either set the patientlist or an error!
        patientListListener = try patientsCollection
            .addSnapshotListener { snapshot, error in
                // TODO check empty stuff?
                guard let snapshot else {
                    // TODO set the view state!
                    print("Encountered fetching document: \(error)")
                    return
                }

                do {
                    self.patientList = try snapshot.documents.map { document in
                        print("Patient: \(document.data())") // TODO remove!
                        return try document.data(as: Patient.self)
                    }
                } catch {
                    print("mapping documents: \(error)")
                    // TODO this are only codable errors!
                }
            }
    }

    func closeList() {
        if let patientListListener {
            patientListListener.remove()
            self.patientListListener = nil
        }
    }

    func add(patient: NewPatientModel) async throws {
        let patient = Patient(from: patient)

        do {
            try await patientsCollection
                .addDocument(from: patient)
        } catch {
            throw FirestoreError(error)
            // TODO encoding errors?
        }
    }

    func loadActivePatient(for id: String) throws {
        removeActivePatientListener()

        // TODO unregister!
        self.activePatientListener = try patientsCollection.document(id).addSnapshotListener { snapshot, error in
            guard let snapshot else {
                print("Error fetching active patient: \(error)")
                return
            }

            do {
                self.activePatient = try snapshot.data(as: Patient.self)
            } catch {
                print("mapping documents: \(error)")
                // TODO this are only codable errors
            }
        }
    }

    func removeActivePatientListener() {
        if let activePatientListener {
            activePatientListener.remove()
            self.activePatientListener = nil
        }
    }

    func retrievePatient(for id: String) async throws -> Patient {
        fatalError("Whatever!")
    }

    func retrievePatients() async throws -> [Patient] {
        // TODO this needs heavy optimization
        do {
            // TODO realtime updates! https://firebase.google.com/docs/firestore/query-data/listen
            let documents = try await patientsCollection.getDocuments().documents

            return try documents.map { document in
                try document.data(as: Patient.self)
            }
        } catch {
            throw FirestoreError(error) // TODO are we mapping decoding errors?
        }
    }
}
