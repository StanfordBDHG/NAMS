//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


struct NAMSSignUp: View {
    var body: some View {
        SignUp {
            IconView()
                .padding(.top, 32)
            Text("SIGN_UP_SUBTITLE")
                .multilineTextAlignment(.center)
                .padding()
            Spacer(minLength: 0)
        }
            .navigationBarTitleDisplayMode(.large)
    }
}


#if DEBUG
struct NAMSSignUp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NAMSSignUp()
                .environmentObject(Account(accountServices: [EmailPasswordAccountService()]))
        }
    }
}
#endif
