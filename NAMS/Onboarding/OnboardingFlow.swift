//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziFirebaseAccount
import SpeziOnboarding
import SwiftUI


/// Displays an multi-step onboarding flow for the Neurodevelopment Assessment and Monitoring System (NAMS).
struct OnboardingFlow: View {
    @EnvironmentObject private var scheduler: NAMSScheduler

    @AppStorage(StorageKeys.onboardingFlowComplete)
    private var completedOnboardingFlow = false

    @State private var localNotificationAuthorization = false
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()

            if !FeatureFlags.disableFirebase {
                AccountSetup()
            }

            if !localNotificationAuthorization {
                NotificationPermissions()
            }

            FinishedSetup()
        }
            .task {
                localNotificationAuthorization = await scheduler.localNotificationAuthorization
            }
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow()
            .environmentObject(Account(accountServices: []))
            .environmentObject(FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099)))
    }
}
#endif
