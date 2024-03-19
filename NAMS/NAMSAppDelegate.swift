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
import SpeziFirebaseStorage
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

            Firestore(settings: firestoreSettings)

            if FeatureFlags.useFirebaseEmulator {
                FirebaseAccountConfiguration(
                    authenticationMethods: methods,
                    emulatorSettings: (host: "localhost", port: 9099)
                )
                FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
            } else {
                FirebaseAccountConfiguration(authenticationMethods: methods)
                FirebaseStorageConfiguration()
            }

            DeviceCoordinator()
            EEGRecordings()

            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
        }
    }
    
    
    private var firestoreSettings: FirestoreSettings {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return settings
    }
}
