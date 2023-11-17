//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore


struct DeviceInformation {
    let syncRatio: Double
    let syncMode: Bool
    let memoryWriteNumber: UInt16
    let memoryEraseMode: Bool
    let batteryLevel: UInt8
    let temperatureValue: UInt8
    let batteryCharging: Bool
}


extension DeviceInformation {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 15 else {
            return nil
        }

        guard let syncRatioData = byteBuffer.readData(length: 8),
              let syncMode = byteBuffer.readInteger(as: UInt8.self),
              let memoryWriteNumber = byteBuffer.readInteger(as: UInt16.self),
              let memoryEraseMode = byteBuffer.readInteger(as: UInt8.self),
              let batteryLevel = byteBuffer.readInteger(as: UInt8.self),
              let temperatureValue = byteBuffer.readInteger(as: UInt8.self),
              let batteryCharging = byteBuffer.readInteger(as: UInt8.self) else {
            return nil
        }

        self .syncRatio = syncRatioData.withUnsafeBytes { pointer in
            pointer.load(as: Double.self)
        }
        self.syncMode = syncMode == 1
        self.memoryWriteNumber = memoryWriteNumber
        self.memoryEraseMode = memoryEraseMode == 1
        self.batteryLevel = batteryLevel
        self.temperatureValue = temperatureValue
        self.batteryCharging = !(batteryCharging == 1) // documentation is wrong, this bit is flipped for some reason
    }
}
