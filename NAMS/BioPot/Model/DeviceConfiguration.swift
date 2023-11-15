//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore // TODO: dependency?


struct DeviceConfiguration {
    let channelCount: UInt8
    let accelerometerStatus: UInt8 // TODO: properly type that!
    let impedanceStatus: Bool
    let memoryStatus: Bool
    let samplesPerChannel: UInt8
    let dataSize: UInt8
    let syncEnabled: Bool
    let serialNumber: String // 4 bytes
}
