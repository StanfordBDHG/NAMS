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
        Configuration {
            let methods: FirebaseAuthAuthenticationMethods = [.emailAndPassword, .signInWithApple]

            AccountConfiguration(configuration: [
                .requires(\.userId),
                .requires(\.name)
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

            Bluetooth(services: [
                // TODO specify bluetooth only supports a single device?
                /*BluetoothService(
                    serviceUUID: .init(string: "0000180A-0000-1000-8000-00805F9B34FB"), // device information service
                    characteristicUUIDs: [
                        .init(string: "00002A26-0000-1000-8000-00805F9B34FB") // firmware revision string
                    ]
                ),*/
                BluetoothService(
                    serviceUUID: BiopotDevice.Service.biopot,
                    characteristicUUIDs: [
                        BiopotDevice.Characteristic.biopotDeviceInfo,
                        BiopotDevice.Characteristic.biopotDeviceConfiguration
                    ]
                )
            ])

            BiopotDevice()
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
