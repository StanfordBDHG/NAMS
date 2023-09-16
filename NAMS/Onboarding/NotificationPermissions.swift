//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SpeziFHIR
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


struct NotificationPermissions: View {
    @EnvironmentObject var scheduler: NAMSScheduler
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @State var notificationProcessing = false


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
                    "NOTIFICATION_PERMISSIONS_BUTTON",
                    action: {
                        do {
                            notificationProcessing = true
                            // notifications are not available in the preview simulator.
                            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                try await scheduler.requestLocalNotificationAuthorization()
                            }
                        } catch {
                            print("Could not request notification permissions.")
                        }
                        notificationProcessing = false
                        onboardingSteps.append(.finished)
                    }
                )
            }
        )
        .navigationBarBackButtonHidden(notificationProcessing)
    }


    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


#if DEBUG
struct NotificationPermissions_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []

    static var previews: some View {
        NotificationPermissions(onboardingSteps: $path)
    }
}
#endif
