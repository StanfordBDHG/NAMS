//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore


enum AccelerometerStatus: UInt8, Equatable {
    case off = 0
    case dynamicallySelectable2g = 1
    case dynamicallySelectable4g = 2
    case dynamicallySelectable8g = 3
    case dynamicallySelectable16g = 4
}


struct DeviceConfiguration {
    let channelCount: UInt8
    let accelerometerStatus: AccelerometerStatus
    let impedanceStatus: Bool
    let memoryStatus: Bool
    let samplesPerChannel: UInt8
    /// Data size in bits. Typically 24-bits.
    let dataSize: UInt8
    let syncEnabled: Bool
    let serialNumber: UInt32
}


extension DeviceConfiguration: ByteCodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 16 else {
            return nil
        }

        byteBuffer.moveReaderIndex(to: 5) // reserved bytes

        guard let channelCount = byteBuffer.readInteger(as: UInt8.self),
              let accelerometerStatusNum = byteBuffer.readInteger(as: UInt8.self),
              let accelerometerStatus = AccelerometerStatus(rawValue: accelerometerStatusNum),
              let impedanceStatus = byteBuffer.readInteger(as: UInt8.self),
              let memoryStatus = byteBuffer.readInteger(as: UInt8.self),
              let samplesPerChannel = byteBuffer.readInteger(as: UInt8.self),
              let dataSize = byteBuffer.readInteger(as: UInt8.self),
              let syncEnabled = byteBuffer.readInteger(as: UInt8.self),
              let serialNumber = byteBuffer.readInteger(as: UInt32.self) else {
            return nil
        }


        self.channelCount = channelCount
        self.accelerometerStatus = accelerometerStatus
        self.impedanceStatus = impedanceStatus == 1
        self.memoryStatus = memoryStatus == 1
        self.samplesPerChannel = samplesPerChannel
        self.dataSize = dataSize
        self.syncEnabled = syncEnabled == 1
        self.serialNumber = serialNumber
    }


    func encode(to byteBuffer: inout ByteBuffer) {
        byteBuffer.reserveCapacity(minimumWritableBytes: 16)

        byteBuffer.writeRepeatingByte(0, count: 5) // reserved bytes, we just write zeros for now

        byteBuffer.writeInteger(channelCount)
        byteBuffer.writeInteger(accelerometerStatus.rawValue)
        byteBuffer.writeInteger(impedanceStatus ? 1 : 0, as: UInt8.self)
        byteBuffer.writeInteger(memoryStatus ? 1 : 0, as: UInt8.self)
        byteBuffer.writeInteger(samplesPerChannel)
        byteBuffer.writeInteger(dataSize)
        byteBuffer.writeInteger(syncEnabled ? 1 : 0, as: UInt8.self)
        byteBuffer.writeInteger(serialNumber)
    }
}
