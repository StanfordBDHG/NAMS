//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth
import SwiftUI


private class PreviewDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            Bluetooth()
            BiopotDevice()
        }
    }
}


extension View {
    func biopotPreviewSetup() -> some View {
        self
            .spezi(PreviewDelegate())
    }
}
