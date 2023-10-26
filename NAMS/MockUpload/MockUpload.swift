//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziMockWebService
import SwiftUI


struct MockUpload: View {
    @Binding private var presentingAccount: Bool

    var body: some View {
        NavigationStack {
            RequestList()
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }


    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}


#if DEBUG
struct MockUpload_Previews: PreviewProvider {
    static var previews: some View {
        MockUpload(presentingAccount: .constant(true))
            .environmentObject(MockWebService())
    }
}
#endif
