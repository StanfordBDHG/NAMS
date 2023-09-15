//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


struct NAMSLogin: View {
    var body: some View {
        Login {
            IconView()
                .padding(.top, 32)
            Text("LOGIN_SUBTITLE")
                .multilineTextAlignment(.center)
                .padding()
                .padding()
            Spacer(minLength: 0)
        }
            .navigationBarTitleDisplayMode(.large)
    }
}


#if DEBUG
struct NAMSLogin_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NAMSLogin()
                .environmentObject(Account(accountServices: []))
        }
    }
}
#endif
