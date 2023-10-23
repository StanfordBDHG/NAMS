//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct AddPatientView: View {
    // TODO form view model
    @Environment(\.dismiss)
    var dismiss

    @State
    var firstname: String = ""
    @State
    var lastname: String = ""
    @State
    var notes: String = ""

    @State
    var showCancellationConfirmation = false

    var shouldAskForCancelConfirmation: Bool {
        !firstname.isEmpty || !lastname.isEmpty || !notes.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {


                Form {
                    Section("Details") {
                        TextField("First name", text: $firstname)
                        TextField("Last name", text: $lastname)
                    }

                    Section("Notes") {
                        TextField("Add Notes", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                    .autocorrectionDisabled(true)
            }
                .navigationTitle("Add Patient")
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog("Are you sure you want to discard this new patient?", isPresented: $showCancellationConfirmation, actions: {
                    Button("Discard Changes", role: .destructive, action: {
                        dismiss()
                    })
                    Button("Keep Editing", role: .cancel, action: {

                    })
                })
                .toolbar {
                    toolbar
                }
                // TODO use UIKit to show dismiss dialog on interactive dimiss: https://peterfriese.dev/posts/swiftui-confirmation-dialogs/
                .interactiveDismissDisabled(shouldAskForCancelConfirmation) // TODO can we pop up the confirmation on interactive dimsiss
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel, action: {
                if shouldAskForCancelConfirmation {
                    showCancellationConfirmation = true
                } else {
                    dismiss()
                }
            }) {
                Text("Cancel")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                print("Creating patient")
                dismiss()
            }) {
                Text("Done") // TODO replace by Save?}
            }
        }
    }
}

#if DEBUG
struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        AddPatientView()
    }
}
#endif
