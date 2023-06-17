//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFHIR
import SpeziFHIRMockDataStorageProvider
import SpeziFHIRToFirestoreAdapter
import SpeziFirebaseAccount
import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import FirebaseAuth
import SpeziFirestore
import SpeziFirestorePrefixUserIdAdapter
import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI


class NAMSAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            if !FeatureFlags.disableFirebase {
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099))
                } else {
                    FirebaseAccountConfiguration()
                }
                firestore
            }
            QuestionnaireDataSource()
            MockDataStorageProvider()
            NAMSScheduler()
        }
    }
    
    
    private var firestore: Firestore<FHIR> {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            adapter: {
                FHIRToFirestoreAdapter()
                FirestorePrefixUserIdAdapter()
            },
            settings: settings
        )
    }
}
