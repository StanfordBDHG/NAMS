//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import SpeziBluetooth


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


extension AccelerometerStatus: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let value = UInt8(from: &byteBuffer) else {
            return nil
        }
        self.init(rawValue: value)
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        rawValue.encode(to: &byteBuffer)
    }
}


extension DeviceConfiguration: ByteCodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 16 else {
            return nil
        }

        byteBuffer.moveReaderIndex(to: 5) // reserved bytes

        guard let channelCount = UInt8(from: &byteBuffer),
              let accelerometerStatus = AccelerometerStatus(from: &byteBuffer),
              let impedanceStatus = Bool(from: &byteBuffer),
              let memoryStatus = Bool(from: &byteBuffer),
              let samplesPerChannel = UInt8(from: &byteBuffer),
              let dataSize = UInt8(from: &byteBuffer),
              let syncEnabled = Bool(from: &byteBuffer),
              let serialNumber = byteBuffer.readInteger(endianness: .big, as: UInt32.self) else {
            return nil
        }


        self.channelCount = channelCount
        self.accelerometerStatus = accelerometerStatus
        self.impedanceStatus = impedanceStatus
        self.memoryStatus = memoryStatus
        self.samplesPerChannel = samplesPerChannel
        self.dataSize = dataSize
        self.syncEnabled = syncEnabled
        self.serialNumber = serialNumber
    }


    func encode(to byteBuffer: inout ByteBuffer) {
        byteBuffer.reserveCapacity(minimumWritableBytes: 16)

        byteBuffer.writeRepeatingByte(0, count: 5) // reserved bytes, we just write zeros for now

        channelCount.encode(to: &byteBuffer)
        accelerometerStatus.encode(to: &byteBuffer)
        impedanceStatus.encode(to: &byteBuffer)
        memoryStatus.encode(to: &byteBuffer)
        samplesPerChannel.encode(to: &byteBuffer)
        dataSize.encode(to: &byteBuffer)
        syncEnabled.encode(to: &byteBuffer)
        byteBuffer.writeInteger(serialNumber, endianness: .big)
    }
}
