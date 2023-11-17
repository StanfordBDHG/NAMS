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
    @AppStorage(StorageKeys.onboardingFlowComplete)
    private var completedOnboardingFlow = false

    @State private var localNotificationAuthorization = false
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()

            AccountOnboarding()

            if !localNotificationAuthorization {
                NotificationPermissions()
            }

            FinishedSetup()
        }
            .task {
                localNotificationAuthorization = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
            }
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
        .environment(Account(MockUserIdPasswordAccountService()))
}
#endif
