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
    private struct IntervalStep {
        let lowerBound: Int
        let stepValue: Int
    }

    private let intervalSteps: [IntervalStep] = [
        .init(lowerBound: 100, stepValue: 10),
        .init(lowerBound: 500, stepValue: 50),
        .init(lowerBound: 2000, stepValue: 250),
        .init(lowerBound: 5000, stepValue: 500),
        .init(lowerBound: 10_000, stepValue: 1000),
        .init(lowerBound: 20_000, stepValue: 2500)
    ]
    private let maxStepValue = 10_000

    @Environment(\.dismiss)
    private var dismiss

    @Binding private var displayInterval: TimeInterval
    @Binding private var valueInterval: Int

    private var intervalStepValue: Int {
        let step = intervalSteps.first { step in
            valueInterval <= step.lowerBound
        }

        return step?.stepValue ?? maxStepValue
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
            in: 10...100_000,
            step: intervalStepValue
        ) {
            ListRow("Value Interval") {
                Text(verbatim: "\(valueInterval)uV")
            }
        }
        .onChange(of: valueInterval) { oldValue, newValue in
            // workaround that we cannot specify different step values for the respective directions.
            // We are not using onIncrement and onDecrement closures as these don't allow a value range (that disable the buttons).

            guard let stepIndex = intervalSteps.firstIndex(where: { $0.lowerBound == oldValue }) else {
                return
            }

            let step = intervalSteps[stepIndex]
            guard newValue == oldValue + step.stepValue else {
                return
            }

            let nextStepValue = stepIndex + 1 < intervalSteps.count ? intervalSteps[stepIndex + 1].stepValue : maxStepValue
            valueInterval = oldValue + nextStepValue
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
