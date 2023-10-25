//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// Constants shared across the NAMS app to access storage information including the `AppStorage` and `SceneStorage`
enum StorageKeys {
    // MARK: - Onboarding
    /// A `Bool` flag indicating of the onboarding was completed.
    static let onboardingFlowComplete = "onboardingFlow.complete"
    /// A `Step` flag indicating the current step in the onboarding process.
    static let onboardingFlowStep = "onboardingFlow.step"
    
    
    // MARK: - Home
    /// The currently selected home tab.
    static let homeTabSelection = "home.tabselection"
    /// The currently selected patient.
    static let selectedPatient = "active.patient"
}
