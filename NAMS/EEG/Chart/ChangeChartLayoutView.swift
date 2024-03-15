//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ChangeChartLayoutView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Binding private var displayInterval: TimeInterval
    @Binding private var valueInterval: Int

    var body: some View {
        List {
            Section {
                axisSteppers
            } footer: {
                Text("Change the value ranges of the X and Y axis.")
            }
        }
            .navigationTitle("Chart Layout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
    }


    @ViewBuilder private var axisSteppers: some View {
        Stepper(
            value: $displayInterval,
            in: 4.0...15.0,
            step: 0.5
        ) {
            HStack {
                Text("Display Interval")
                Spacer()
                Text(verbatim: "\(String(format: "%.1f", displayInterval))s")
                    .foregroundColor(.secondary)
            }
        }
        Stepper(
            value: $valueInterval,
            in: 10...2000,
            step: 5 // TODO: steps are not linear!
        ) {
            HStack {
                Text("Value Interval")
                Spacer()
                Text(verbatim: "\(valueInterval)uV")
                    .foregroundColor(.secondary)
            }
        }
    }


    init(displayInterval: Binding<TimeInterval>, valueInterval: Binding<Int>) {
        self._displayInterval = displayInterval
        self._valueInterval = valueInterval
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ChangeChartLayoutView(displayInterval: .constant(7), valueInterval: .constant(300))
    }
}
#endif
