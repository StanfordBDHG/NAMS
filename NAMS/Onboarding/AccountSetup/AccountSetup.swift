//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import SpeziAccount
import SpeziFirebaseAccount
import SpeziOnboarding
import SwiftUI


struct AccountSetup: View {
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @EnvironmentObject private var account: Account
    @EnvironmentObject private var scheduler: NAMSScheduler
    @EnvironmentObject private var standard: NAMSStandard
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "ACCOUNT_TITLE",
                        subtitle: "ACCOUNT_SUBTITLE"
                    )
                    Spacer(minLength: 0)
                    accountImage
                    accountDescription
                    Spacer(minLength: 0)
                }
            }, actionView: {
                actionView
            }
        )
            .onReceive(account.objectWillChange) {
                if account.signedIn {
                    Task { @MainActor in
                        await moveToNextOnboardingStep()
                    }
                }
            }
    }
    
    @ViewBuilder private var accountImage: some View {
        Group {
            if account.signedIn {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "person.fill.badge.plus")
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            }
        }
            .font(.system(size: 150))
            .foregroundColor(.accentColor)
    }
    
    @ViewBuilder private var accountDescription: some View {
        VStack {
            Group {
                if account.signedIn {
                    Text("ACCOUNT_SIGNED_IN_DESCRIPTION")
                } else {
                    Text("ACCOUNT_SETUP_DESCRIPTION")
                }
            }
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)

            if account.signedIn {
                UserView()
                    .padding()
                Button("Logout", role: .destructive) {
                    // workaround as of https://github.com/StanfordSpezi/SpeziTemplateApplication/issues/21
                    account.signedIn = false

                    try? Auth.auth().signOut()
                }
            }
        }
    }
    
    @ViewBuilder private var actionView: some View {
        if account.signedIn {
            OnboardingActionsView(
                "ACCOUNT_NEXT",
                action: {
                    await moveToNextOnboardingStep()
                }
            )
        } else {
            OnboardingActionsView(
                primaryText: "ACCOUNT_SIGN_UP",
                primaryAction: {
                    onboardingSteps.append(.signUp)
                },
                secondaryText: "ACCOUNT_LOGIN",
                secondaryAction: {
                    onboardingSteps.append(.login)
                }
            )
        }
    }
    
    
    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }


    @MainActor
    private func moveToNextOnboardingStep() async {
        if await !scheduler.localNotificationAuthorization {
            onboardingSteps.append(.notificationPermissions)
        } else {
            onboardingSteps.append(.finished)
        }

        await standard.signedIn()

        // Unfortunately, SwiftUI currently animates changes in the navigation path that do not change
        // the current top view. Therefore we need to do the following async procedure to remove the
        // `.login` and `.signUp` steps while disabling the animations before and re-enabling them
        // after the elements have been changed.
        try? await Task.sleep(for: .seconds(1.0))
        UIView.setAnimationsEnabled(false)
        onboardingSteps.removeAll(where: { $0 == .login || $0 == .signUp })
        try? await Task.sleep(for: .seconds(1.0))
        UIView.setAnimationsEnabled(true)
    }
}


#if DEBUG
struct AccountSetup_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []

    static var previews: some View {
        AccountSetup(onboardingSteps: $path)
            .environmentObject(Account(accountServices: []))
            .environmentObject(FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099)))
    }
}
#endif
