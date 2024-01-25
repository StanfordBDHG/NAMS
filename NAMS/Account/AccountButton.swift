//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountButton: View {
    @Binding private var isPresented: Bool


    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Image(systemName: "person.crop.circle")
        }
            .accessibilityLabel("Your Account")
    }


    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
}


#if DEBUG
#Preview {
    AccountButton(isPresented: .constant(false))
}
#endif
