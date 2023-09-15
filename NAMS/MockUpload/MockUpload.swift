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
    var body: some View {
        NavigationStack {
            RequestList()
        }
    }
}


#if DEBUG
struct MockUpload_Previews: PreviewProvider {
    static var previews: some View {
        MockUpload()
            .environmentObject(MockWebService())
    }
}
#endif
