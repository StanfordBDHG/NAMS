//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Observation
import OrderedCollections
import OSLog
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziViews
import SwiftUI


@MainActor
@Observable
class PatientListModel {
    static let logger = Logger(subsystem: "edu.stanford.NAMS", category: "PatientListModel")

    var patientList: [Patient]? // swiftlint:disable:this discouraged_optional_collection

    @AppStorage(StorageKeys.selectedPatient)
    @ObservationIgnored private var _activePatientId: String?

    var activePatientId: String? {
        get {
            access(keyPath: \.activePatientId)
            return _activePatientId
        }
        set {
            withMutation(keyPath: \.activePatientId) {
                _activePatientId = newValue
            }
        }
    }

    var activePatient: Patient?

    var completedTasks: [CompletedTask]? // swiftlint:disable:this discouraged_optional_collection
    var completedTaskIds: [String]? { // swiftlint:disable:this discouraged_optional_collection
        guard let completedTasks else {
            return nil
        }
        return completedTasks.map { $0.taskId }
    }

    var categorizedPatients: OrderedDictionary<Character, [Patient]> = [:]

    @ObservationIgnored private var patientListListener: ListenerRegistration?
    @ObservationIgnored private var activePatientListener: ListenerRegistration?
    @ObservationIgnored private var activePatientCompletedTaskListener: ListenerRegistration?

    private var patientsCollection: CollectionReference {
        Firestore.firestore().collection("patients")
    }


    init() {}


    func completedTasksCollection(patientId: String) -> CollectionReference {
        patientsCollection
            .document(patientId)
            .collection("completedTasks")
    }


    func retrieveList(viewState: Binding<ViewState>) {
        closeList()

        // for ordered queries, Firebase requires an index that is to be created manually
        patientListListener = patientsCollection
            .order(by: "name.givenName")
            .order(by: "name.familyName")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {
                    return
                }

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

    func add(task: CompletedTask) async throws {
        guard let activePatient,
              let patientId = activePatient.id else {
            Self.logger.error("Couldn't save completed task \(task.taskId). No patient found!")
            throw QuestionnaireError.missingPatient
        }

        do {
            try await completedTasksCollection(patientId: patientId)
                .addDocument(from: task)
        } catch {
            Self.logger.error("Failed to save completed task \(task.taskId)!")
            throw FirestoreError(error)
        }
    }

    func remove(patientId: String, viewState: Binding<ViewState>) async {
        if let activePatient, activePatient.id == patientId {
            removeActivePatientListener()
        }

        if patientId == activePatientId {
            activePatientId = nil
        }

        do {
            Self.logger.info("Deleting patient with ")
            try await patientsCollection.document(patientId).delete()
        } catch {
            viewState.wrappedValue = .error(FirestoreError(error))
        }
    }

    func loadActivePatient(for id: String, viewState: Binding<ViewState>) {
        if activePatient?.id == id {
            return // already set up
        }

        removeActivePatientListener()

        self.activePatientListener = patientsCollection.document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else {
                return
            }

            guard let snapshot else {
                Self.logger.error("Failed to retrieve active patient: \(error)")
                viewState.wrappedValue = .error(FirestoreError(error!)) // swiftlint:disable:this force_unwrapping
                return
            }

            if !snapshot.exists {
                self.activePatientId = nil
                self.removeActivePatientListener()
                return
            }

            do {
                self.activePatient = try snapshot.data(as: Patient.self)
            } catch {
                if error is DecodingError {
                    Self.logger.error("Failed to decode active patient: \(error)")
                    viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                } else {
                    Self.logger.error("Unexpected error occurred while decoding active patient: \(error)")
                    viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                }
            }
        }

        self.loadCompletedTasks(patientId: id, viewState: viewState)
    }

    private func loadCompletedTasks(patientId: String, viewState: Binding<ViewState>) {
        if activePatientCompletedTaskListener != nil {
            return
        }

        self.activePatientCompletedTaskListener = completedTasksCollection(patientId: patientId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {
                    return
                }

                guard let snapshot else {
                    Self.logger.error("Failed to retrieve questionnaire responses for active patient: \(error)")
                    viewState.wrappedValue = .error(FirestoreError(error!)) // swiftlint:disable:this force_unwrapping
                    return
                }

                do {
                    self.completedTasks = try snapshot.documents.map { document in
                        try document.data(as: CompletedTask.self)
                    }
                } catch {
                    if error is DecodingError {
                        Self.logger.error("Failed to decode completed questionnaires: \(error)")
                        viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                    } else {
                        Self.logger.error("Unexpected error occurred while decoding completed questionnaires: \(error)")
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

        if let activePatientCompletedTaskListener {
            activePatientCompletedTaskListener.remove()
            self.activePatientCompletedTaskListener = nil
        }
    }

    func setupTestEnvironment(withPatient patientId: String, viewState: Binding<ViewState>, account: Account) async {
        await setupTestAccount(account: account, viewState: viewState)

        do {
            try await patientsCollection.document(patientId).setData(
                from: Patient(name: .init(givenName: "Example", familyName: "Patient")),
                merge: true
            )


            let query = try await completedTasksCollection(patientId: patientId).getDocuments()
            for document in query.documents {
                try await document.reference.delete()
            }
        } catch {
            Self.logger.error("Failed to set test patient information: \(error)")
            viewState.wrappedValue = .error(FirestoreError(error))
        }
    }

    private func setupTestAccount(account: Account, viewState: Binding<ViewState>) async {
        let email = "test@nams.stanford.edu"
        let password = "123456789"

        if let details = account.details,
           details.email == email {
            return
        }

        guard let service = account.registeredAccountServices.compactMap({ $0 as? any UserIdPasswordAccountService }).first else {
            preconditionFailure("Failed to retrieve a user-id-password based account service for test account setup!")
        }

        do {
            // let the initial stateChangeDelegate of FirebaseAuth get called. Otherwise, we will interfere with that.
            try await Task.sleep(for: .milliseconds(500))

            do {
                let details = SignupDetails.Builder()
                    .set(\.userId, value: email)
                    .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
                    .set(\.password, value: password)
                    .build()
                try await service.signUp(signupDetails: details)
            } catch {
                if "\(error)".contains("accountAlreadyInUse") {
                    try await service.login(userId: email, password: password)
                } else {
                    throw error
                }
            }
        } catch {
            Self.logger.error("Failed setting up test account : \(error)")
            viewState.wrappedValue = .error(AnyLocalizedError(error: error))
        }
    }
}
