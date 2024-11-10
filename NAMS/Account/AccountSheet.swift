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


struct AccountSheet: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.accountRequired)
    var accountRequired

    @Environment(Account.self)
    private var account
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator


    @State var isInSetup = false

    
    var body: some View {
        @Bindable var deviceCoordinator = deviceCoordinator
        NavigationStack {
            if account.signedIn && !isInSetup {
                AccountOverview(close: .showCloseButton) {
                    Section("Developer") {
                        Toggle(isOn: $deviceCoordinator.enableMockDevice) {
                            Text("Show Mock Devices")
                        }
                    }
                }
            } else {
                AccountSetup { _ in
                    dismiss() // we just signed in, dismiss the account setup sheet
                } header: {
                    AccountSetupHeader()
                }
                    .onAppear {
                        isInSetup = true
                    }
                    .toolbar {
                        if !accountRequired {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    dismiss()
                                }
                            }
                        }
                    }
            }
        }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.accountId = UUID().uuidString
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
            DeviceCoordinator()
        }
}

#Preview {
    AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
            DeviceCoordinator()
        }
}
#endif
