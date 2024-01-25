//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Defines onboarding views that are shown in the Xcode preview simulator
extension OnboardingFlow {
    static let previewSimulatorViews: [any View] = {
        [Welcome(), AccountOnboarding(), NotificationPermissions(), FinishedSetup()]
    }()
}
