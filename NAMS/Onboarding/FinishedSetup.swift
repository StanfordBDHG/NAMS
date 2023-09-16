//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziOnboarding
import SwiftUI

struct FinishedSetup: View {
    @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath

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
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(uiColor: .systemGreen), Color.accentColor)
                        .font(.system(size: 150))
                        .padding(.vertical, 20)
                        .accessibilityHidden(true)


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
                    onboardingNavigationPath.nextStep()
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
