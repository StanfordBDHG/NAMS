//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@main
struct NAMSApp: App {
    @UIApplicationDelegateAdaptor(NAMSAppDelegate.self)
    var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete)
    var completedOnboardingFlow = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView()
                } else {
                    EmptyView()
                }
            }
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .firebaseAccount()
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
