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
    @EnvironmentObject private var account: Account
    @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath

    @State private var signingOutPretrigger = false
    
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
            } // TODO can we put the next button in a toolbar? (logged in state is scrollable!
        )
            .onReceive(account.objectWillChange) {
                if !signingOutPretrigger {
                    if account.signedIn {
                        onboardingNavigationPath.nextStep()
                    }
                } else {
                    signingOutPretrigger = false
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
                    Text("ACCOUNT_SIGNED_IN_DESCRIPTION") // TODO this text does not wrap to the next line!
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
                    signingOutPretrigger = true
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
                    onboardingNavigationPath.nextStep()
                }
            )
        } else {
            OnboardingActionsView(
                primaryText: "ACCOUNT_SIGN_UP",
                primaryAction: {
                    onboardingNavigationPath.append(customView: NAMSSignUp())
                },
                secondaryText: "ACCOUNT_LOGIN",
                secondaryAction: {
                    onboardingNavigationPath.append(customView: NAMSLogin())
                }
            )
        }
    }
}


#if DEBUG
struct AccountSetup_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: AccountSetup.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
            .environmentObject(Account(accountServices: []))
            .environmentObject(FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099)))
    }
}
#endif
