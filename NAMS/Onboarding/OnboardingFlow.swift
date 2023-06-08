//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Displays an multi-step onboarding flow for the Neurodevelopment Assessment and Monitoring System (NAMS).
struct OnboardingFlow: View {
    enum Step: String, Codable {
        case interestingModules
        case consent
        case accountSetup
        case login
        case signUp
        case healthKitPermissions
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
                    case .interestingModules:
                        InterestingModules(onboardingSteps: $onboardingSteps)
                    case .consent:
                        Consent(onboardingSteps: $onboardingSteps)
                    case .accountSetup:
                        AccountSetup(onboardingSteps: $onboardingSteps)
                    case .login:
                        NAMSLogin()
                    case .signUp:
                        NAMSSignUp()
                    case .healthKitPermissions:
                        HealthKitPermissions()
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
    }
}
#endif
