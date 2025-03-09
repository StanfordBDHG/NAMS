//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport)
import SpeziAccount
import SwiftUI


struct AccountSetupHeader: View {
    @Environment(Account.self)
    private var account
    @Environment(\.accountSetupState)
    private var setupState

    
    var body: some View {
        VStack {
            Text("Your Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
                .padding(.top, 30)
            Text("Your Account Description", comment: "What is an account used for in this app?")
                .padding(.bottom, 8)

            if account.signedIn, case .presentingExistingAccount = setupState {
                Text("You are already signed in.", comment: "Account Setup Header Description")
            } else {
                Text("You may login below.", comment: "Account Setup Header Description")
            }
        }
            .multilineTextAlignment(.center)
    }
}


#if DEBUG
#Preview {
    AccountSetupHeader()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
