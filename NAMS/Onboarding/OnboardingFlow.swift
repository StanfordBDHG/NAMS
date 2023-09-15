//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziFirebaseAccount
import SwiftUI


/// Displays an multi-step onboarding flow for the Neurodevelopment Assessment and Monitoring System (NAMS).
struct OnboardingFlow: View {
    enum Step: String, Codable {
        case accountSetup
        case login
        case signUp
        case finished
    }
    
    @SceneStorage(StorageKeys.onboardingFlowStep)
    private var onboardingSteps: [Step] = []
    @AppStorage(StorageKeys.onboardingFlowComplete)
    var completedOnboardingFlow = false
    
    var body: some View {
        NavigationStack(path: $onboardingSteps) {
            Welcome(onboardingSteps: $onboardingSteps)
                .navigationDestination(for: Step.self) { onboardingStep in
                    switch onboardingStep {
                    case .accountSetup:
                        AccountSetup(onboardingSteps: $onboardingSteps)
                    case .login:
                        NAMSLogin()
                    case .signUp:
                        NAMSSignUp()
                    case .finished:
                        FinishedSetup()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
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
