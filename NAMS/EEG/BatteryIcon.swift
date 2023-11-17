//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct BatteryIcon: View {
    private let percentage: Int

    var body: some View {
        Text(verbatim: "\(percentage) %")
        batteryIcon(percentage: percentage) // hides accessibility, only text will be shown
            .foregroundStyle(.primary)
    }


    init(percentage: Int) {
        self.percentage = percentage
    }

    @ViewBuilder
    func batteryIcon(percentage: Int) -> some View {
        Group {
            if percentage >= 90 {
                Image(systemName: "battery.100")
            } else if percentage >= 65 {
                Image(systemName: "battery.75")
            } else if percentage >= 40 {
                Image(systemName: "battery.50")
            } else if percentage >= 15 {
                Image(systemName: "battery.25")
            } else if percentage > 3 {
                Image(systemName: "battery.25")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
            } else {
                Image(systemName: "battery.0")
                    .foregroundColor(.red)
            }
        }
        .accessibilityHidden(true)
    }
}


#if DEBUG
#Preview {
    BatteryIcon(percentage: 100)
}

#Preview {
    BatteryIcon(percentage: 70)
}

#Preview {
    BatteryIcon(percentage: 50)
}

#Preview {
    BatteryIcon(percentage: 25)
}

#Preview {
    BatteryIcon(percentage: 10)
}
#endif
