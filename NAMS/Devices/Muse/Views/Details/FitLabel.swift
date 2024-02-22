//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct FitLabel: View {
    private let fit: Fit

    var body: some View {
        Text(fit.localizedStringResource)
            .foregroundStyle(fit.style)
    }

    init(_ fit: Fit) {
        self.fit = fit
    }
}


extension Fit {
    fileprivate var style: Color {
        switch self {
        case .good:
            return .green
        case .mediocre:
            return .orange
        case .poor:
            return .red
        }
    }
}


#if DEBUG
#Preview {
    List {
        FitLabel(.good)
        FitLabel(.mediocre)
        FitLabel(.poor)
    }
}
#endif
