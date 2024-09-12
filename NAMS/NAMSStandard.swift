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


actor NAMSStandard: Standard {
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
}
