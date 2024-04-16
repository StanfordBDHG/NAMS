//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ChangeChartLayoutView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Binding private var displayInterval: TimeInterval
    @Binding private var valueInterval: Int

    private var intervalStepValue: Int {
        if valueInterval <= 100 {
            10
        } else if valueInterval <= 500 {
            25
        } else if valueInterval <= 2000 {
            100
        } else {
            500
        }
    }

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
            ListRow("Display Interval") {
                Text(verbatim: "\(String(format: "%.1f", displayInterval))s")
            }
        }
        Stepper(
            value: $valueInterval,
            in: 10...5000,
            step: intervalStepValue
        ) {
            ListRow("Value Interval") {
                Text(verbatim: "\(valueInterval)uV")
            }
        }
        .onChange(of: valueInterval) { oldValue, newValue in
            // workaround that we cannot specify different step values for the respective directions.
            // We are not using onIncrement and onDecrement closures as these don't allow a value range (that disable the buttons).
            if oldValue == 100 && newValue == 110 {
                valueInterval = 125
            } else if oldValue == 500 && newValue == 525 {
                valueInterval = 600
            } else if oldValue == 2000 && newValue == 2100 {
                valueInterval = 2500
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
    struct StepperView: View {
        @State var displayInterval: TimeInterval = 7.0
        @State var valueInterval = 300

        var body: some View {
            ChangeChartLayoutView(displayInterval: $displayInterval, valueInterval: $valueInterval)
        }
    }
    return NavigationStack {
        StepperView()
    }
}
#endif
