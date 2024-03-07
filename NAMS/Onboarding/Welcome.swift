//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct Welcome: View {
    @Environment(OnboardingNavigationPath.self)
    private var onboardingNavigationPath

    
    var body: some View {
        OnboardingView(
            title: "WELCOME_TITLE",
            subtitle: "Neurodevelopmental Assessment and Monitoring System",
            areas: [
                .init(
                    icon: Image(systemName: "person.2.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA1_TITLE",
                    description: "WELCOME_AREA1_DESCRIPTION"
                ),
                .init(
                    icon: Image(systemName: "list.clipboard.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA2_TITLE",
                    description: "WELCOME_AREA2_DESCRIPTION"
                ),
                .init(
                    icon: Image(systemName: "doc.text.below.ecg.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA3_TITLE",
                    description: "WELCOME_AREA3_DESCRIPTION"
                )
            ],
            actionText: "Continue",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack(startAtStep: Welcome.self) {
        for onboardingView in OnboardingFlow.previewSimulatorViews {
            onboardingView
        }
    }
}
#endif
