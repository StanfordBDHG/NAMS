//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import NIOCore
import SpeziBluetooth


struct DeviceInformation {
    let syncRatio: Double
    let syncMode: Bool
    let memoryWriteNumber: UInt16
    let memoryEraseMode: Bool
    let batteryLevel: UInt8
    let temperatureValue: UInt8
    let batteryCharging: Bool
}


extension DeviceInformation: ByteDecodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let syncRatio = byteBuffer.readInteger(endianness: .big, as: UInt64.self),
              let syncMode = Bool(from: &byteBuffer),
              let memoryWriteNumber = byteBuffer.readInteger(endianness: .big, as: UInt16.self),
              let memoryEraseMode = Bool(from: &byteBuffer),
              let batteryLevel = UInt8(from: &byteBuffer),
              let temperatureValue = UInt8(from: &byteBuffer),
              let batteryCharging = Bool(from: &byteBuffer) else {
            return nil
        }

        self.syncRatio = Double(bitPattern: syncRatio)
        self.syncMode = syncMode
        self.memoryWriteNumber = memoryWriteNumber
        self.memoryEraseMode = memoryEraseMode
        self.batteryLevel = batteryLevel
        self.temperatureValue = temperatureValue
        self.batteryCharging = !(batteryCharging) // documentation is wrong, this bit is flipped for some reason
    }
}
