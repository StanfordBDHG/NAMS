//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


#if DEBUG
struct NavigationStackWithPath<Content: View>: View {
    private let content: (Binding<NavigationPath>) -> Content

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            content($path)
        }
    }

    init(@ViewBuilder _ content: @escaping (Binding<NavigationPath>) -> Content) {
        self.content = content
    }
}
#endif


private struct NAMSTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete)
    var completedOnboardingFlow = false
    
    func body(content: Content) -> some View {
        content
            .task {
                if FeatureFlags.skipOnboarding {
                    completedOnboardingFlow = true
                }
                if FeatureFlags.showOnboarding {
                    completedOnboardingFlow = false
                }
            }
    }
}


extension View {
    func testingSetup() -> some View {
        self.modifier(NAMSTestingSetup())
    }
}
