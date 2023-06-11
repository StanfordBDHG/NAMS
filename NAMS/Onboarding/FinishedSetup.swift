//
// Created by Andreas Bauer on 11.06.23.
//

import Foundation
import SwiftUI
import SpeziOnboarding

struct FinishedSetup: View {
    @AppStorage(StorageKeys.onboardingFlowComplete)
    var completedOnboardingFlow = false

    var body: some View {
        OnboardingView(
            titleView: {
                OnboardingTitleView(
                    title: "FINISHED_SETUP_TITLE"
                )
            },
            contentView: {
                Group {
                    Spacer()
                    Image(systemName: "gear.badge.checkmark")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 150))
                        .padding(.vertical, 20)

                    Spacer()
                    Text("FINISHED_SETUP_TEXT")
                        .multilineTextAlignment(.center)
                    Spacer()
                    Spacer()
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView("Start") {
                    completedOnboardingFlow = true
                }
            }
        )
    }
}

#if DEBUG
struct FinishedSetup_Previews: PreviewProvider {
    static var previews: some View {
        FinishedSetup()
    }
}
#endif
