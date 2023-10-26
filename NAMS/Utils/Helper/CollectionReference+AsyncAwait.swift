//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore


extension CollectionReference {
    @discardableResult
    func addDocument<T: Encodable>(from value: T, encoder: Firestore.Encoder = Firestore.Encoder()) async throws -> DocumentReference {
        let encoded = try encoder.encode(value)
        return try await addDocument(data: encoded)
    }
}
