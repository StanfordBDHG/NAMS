//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import FirebaseFirestore
import FirebaseStorage
import Spezi
import SpeziAccount
import SpeziFirebaseAccountStorage


actor NAMSStandard: Standard, AccountStorageConstraint {
    private static var userCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    @Dependency private var storage = FirestoreAccountStorage(storeIn: NAMSStandard.userCollection)

    init() {}

    func uploadEEGRecording(file: URL, recordingId: UUID, patientId: String, format: FileFormat) async throws {
        let reference = Storage.storage()
            .reference()
            .child("patients/\(patientId)")
            .child("eeg-recordings/\(recordingId).\(format.rawValue)")

        let metadata = StorageMetadata()
        metadata.contentType = "application/octet-stream"
        _ = try await reference.putFileAsync(from: file, metadata: metadata)
    }

    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        try await storage.create(identifier, details)
    }
    
    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        try await storage.load(identifier, keys)
    }
    
    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        try await storage.modify(identifier, modifications)
    }
    
    func clear(_ identifier: AdditionalRecordId) async {
        await storage.clear(identifier)
    }
    
    func delete(_ identifier: AdditionalRecordId) async throws {
        try await storage.delete(identifier)
    }
}
