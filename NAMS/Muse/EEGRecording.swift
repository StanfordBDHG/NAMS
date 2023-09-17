//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct EEGRecording: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject var museModel: MuseViewModel

    var body: some View {
        List {
            if let activeMuse = museModel.activeMuse {
                Text("Device: \(activeMuse.muse.getModel().description) - \(activeMuse.muse.getName())")

                Section {
                    let measurements = activeMuse.measurements.suffix(800) // TODO sample rate?
                    let baseTime = activeMuse.measurements.first?.timestamp.timeIntervalSince1970

                    if let baseTime, let lastTime = activeMuse.measurements.last?.timestamp.timeIntervalSince1970 {
                        let asd = print("max time! \(lastTime - baseTime)")
                    }

                    VStack {
                        EEGChart(measurements: measurements, for: .tp9, baseTime: baseTime)
                        EEGChart(measurements: measurements, for: .af7, baseTime: baseTime)
                        EEGChart(measurements: measurements, for: .af8, baseTime: baseTime)
                        EEGChart(measurements: measurements, for: .tp10, baseTime: baseTime)
                    }
                }
                    .listRowBackground(Color.clear)

                Section {
                    Button(role: .destructive, action: {
                        activeMuse.measurements = []
                    }) {
                        Text("Reset")
                    }
                }
            } else {
                Text("No Device connected!") // TODO optimize
            }
        }
            .navigationTitle("EEG Recording")
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
    }

    init(museModel: MuseViewModel) {
        self.museModel = museModel
    }
}


#if DEBUG
struct EEGMeasurement_Previews: PreviewProvider {
    @StateObject static var model = MuseViewModel()
    static var previews: some View {
        NavigationStack {
            EEGRecording(museModel: model)
        }
    }
}
#endif
