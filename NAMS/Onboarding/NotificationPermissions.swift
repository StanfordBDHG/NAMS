//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct NotificationPermissions: View {
    @EnvironmentObject private var standard: NAMSStandard
    @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath

    @State private var notificationProcessing = false


    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "NOTIFICATION_PERMISSIONS_TITLE",
                        subtitle: "NOTIFICATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("NOTIFICATION_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "Continue",
                    action: {
                        do {
                            notificationProcessing = true
                            // Notification Authorization are not available in the preview simulator.
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await Task.sleep(for: .seconds(5))
                            } else {
                                try await standard.requestLocalNotificationAuthorization()
                            }
                        } catch {
                            print("Could not request notification permissions.")
                        }

                        notificationProcessing = false
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(notificationProcessing)
            .navigationTitle(Text(verbatim: "")) // // Small fix as otherwise "Login" or "Sign up" is still shown in the nav bar
    }
}


#if DEBUG
struct NotificationPermissions_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: NotificationPermissions.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
            .environmentObject(NAMSStandard())
    }
}
#endif
