//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

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
    @State var overviewIsEditing = false

    
    var body: some View {
        @Bindable var deviceCoordinator = deviceCoordinator
        NavigationStack {
            if account.signedIn && !isInSetup {
                AccountOverview(isEditing: $overviewIsEditing) {
                    Section("Developer") {
                        Toggle(isOn: $deviceCoordinator.enableMockDevice) {
                            Text("Show Mock Devices")
                        }
                    }
                }
                .onDisappear {
                    overviewIsEditing = false
                }
                .toolbar {
                    if !overviewIsEditing {
                        closeButton
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
                        closeButton
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                dismiss()
            }
        }
    }
}


#if DEBUG
#Preview {
    let details = AccountDetails.Builder()
        .set(\.accountId, value: UUID().uuidString)
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return AccountSheet()
        .previewWith {
            AccountConfiguration(building: details, active: MockUserIdPasswordAccountService())
            DeviceCoordinator()
        }
}

#Preview {
    AccountSheet()
        .previewWith {
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
            DeviceCoordinator()
        }
}
#endif
