//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SpeziBluetooth
import SpeziFirebaseAccount
import SpeziFirestore
import SwiftUI


class NAMSAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: NAMSStandard()) {
            let methods: FirebaseAuthAuthenticationMethods = [.emailAndPassword, .signInWithApple]

            AccountConfiguration(configuration: [
                .requires(\.userId),
                .requires(\.name),
                .collects(\.investigatorCode)
            ])

            if FeatureFlags.useFirebaseEmulator {
                FirebaseAccountConfiguration(
                    authenticationMethods: methods,
                    emulatorSettings: (host: "localhost", port: 9099)
                )
            } else {
                FirebaseAccountConfiguration(authenticationMethods: methods)
            }
            firestore

            DeviceCoordinator()
            EEGRecordings()

            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
        }
    }
    
    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(settings: settings)
    }
}
