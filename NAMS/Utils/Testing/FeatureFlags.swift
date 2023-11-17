//
// This source file is part of the CS342 2023 PAWS Team Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for the NAMS app.
enum FeatureFlags {
    /// Skips the onboarding flow to enable easier development of features in the application and to allow UI tests to skip the onboarding flow.
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
    static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    #if targetEnvironment(simulator)
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    static let useFirebaseEmulator = true
    #else
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    static let useFirebaseEmulator = CommandLine.arguments.contains("--useFirebaseEmulator")
    #endif
    /// Custom accessibility actions cannot be reliably tested. This flag ensures custom accessibility actions
    /// are rendered as UI elements.
    static let renderAccessibilityActions = CommandLine.arguments.contains("--render-accessibility-actions")
    /// A default patient is injected you may use within UI tests.
    static let injectDefaultPatient = CommandLine.arguments.contains("--inject-default-patient")
    /// Enable test specific functionality for the Biopot platform.
    static let testBiopot = CommandLine.arguments.contains("--test-biopot")
}
