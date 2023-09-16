//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MuseDeviceRow: View {
    private let muse: IXNMuse

    @ObservedObject private var museModel: MuseViewModel

    var body: some View {
        HStack {
            Button(action: {
                museModel.tapMuse(muse)
            }) {
                HStack {
                    Text(verbatim: "\(muse.getModel().description) - \(muse.getName().replacingOccurrences(of: "Muse-", with: ""))")
                        .foregroundColor(.primary)
                    Spacer()
                }
            }

            if let activeMuse = museModel.activeMuse,
               activeMuse.muse.getMacAddress() == muse.getMacAddress() {
                // TODO access through the connected model?
                switch activeMuse.state {
                case .connecting:
                    ProgressView()
                case .connected:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true) // TODO accessibility!
                case .needsUpdate, .needsLicense:
                    // TODO make this tapable! with information and instructions on how to update
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                    // TODO accessibility
                case .disconnected, .unknown:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        }
    }


    init(museModel: MuseViewModel, muse: IXNMuse) {
        self.muse = muse
        self.museModel = museModel
    }
}


// TODO how to preview?
