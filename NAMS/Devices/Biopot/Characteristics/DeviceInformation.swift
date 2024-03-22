//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import Foundation
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


extension DeviceInformation: ByteDecodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        let endianness: Endianness = .big
        guard let syncRatio = UInt64(from: &byteBuffer, preferredEndianness: endianness),
              let syncMode = Bool(from: &byteBuffer, preferredEndianness: endianness),
              let memoryWriteNumber = UInt16(from: &byteBuffer, preferredEndianness: endianness),
              let memoryEraseMode = Bool(from: &byteBuffer, preferredEndianness: endianness),
              let batteryLevel = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let temperatureValue = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let batteryCharging = Bool(from: &byteBuffer, preferredEndianness: endianness) else {
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
