//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore


struct DeviceInformation {
    let syncRation: Double
    let syncMode: Bool
    let memoryWriteNumber: UInt16
    let memoryEraseMode: Bool
    let batteryLevel: UInt8
    let temperatureValue: UInt8
    let batteryCharging: Bool

    // TODO: work with bytebuffer
}
