//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
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

    init(
        channelCount: UInt8 = 8,
        accelerometerStatus: AccelerometerStatus = .off,
        impedanceStatus: Bool = false,
        memoryStatus: Bool = false,
        samplesPerChannel: UInt8 = 9,
        dataSize: UInt8 = 24,
        syncEnabled: Bool = false,
        serialNumber: UInt32 = 127
    ) {
        self.channelCount = channelCount
        self.accelerometerStatus = accelerometerStatus
        self.impedanceStatus = impedanceStatus
        self.memoryStatus = memoryStatus
        self.samplesPerChannel = samplesPerChannel
        self.dataSize = dataSize
        self.syncEnabled = syncEnabled
        self.serialNumber = serialNumber
    }
}


extension AccelerometerStatus: PrimitiveByteCodable {
    init?(from byteBuffer: inout ByteBuffer, endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, endianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }

    func encode(to byteBuffer: inout ByteBuffer, endianness: Endianness) {
        rawValue.encode(to: &byteBuffer, endianness: endianness)
    }
}


extension DeviceConfiguration: ByteCodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer) {
        let endianness: Endianness = .big

        guard byteBuffer.readableBytes >= 16 else {
            return nil
        }

        byteBuffer.moveReaderIndex(to: 5) // reserved bytes

        guard let channelCount = UInt8(from: &byteBuffer, endianness: endianness),
              let accelerometerStatus = AccelerometerStatus(from: &byteBuffer, endianness: endianness),
              let impedanceStatus = Bool(from: &byteBuffer, endianness: endianness),
              let memoryStatus = Bool(from: &byteBuffer, endianness: endianness),
              let samplesPerChannel = UInt8(from: &byteBuffer, endianness: endianness),
              let dataSize = UInt8(from: &byteBuffer, endianness: endianness),
              let syncEnabled = Bool(from: &byteBuffer, endianness: endianness),
              let serialNumber = UInt32(from: &byteBuffer, endianness: endianness) else {
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
        let endianness: Endianness = .big

        byteBuffer.reserveCapacity(minimumWritableBytes: 16)

        byteBuffer.writeRepeatingByte(0, count: 5) // reserved bytes, we just write zeros for now

        channelCount.encode(to: &byteBuffer, endianness: endianness)
        accelerometerStatus.encode(to: &byteBuffer, endianness: endianness)
        impedanceStatus.encode(to: &byteBuffer, endianness: endianness)
        memoryStatus.encode(to: &byteBuffer, endianness: endianness)
        samplesPerChannel.encode(to: &byteBuffer, endianness: endianness)
        dataSize.encode(to: &byteBuffer, endianness: endianness)
        syncEnabled.encode(to: &byteBuffer, endianness: endianness)
        serialNumber.encode(to: &byteBuffer, endianness: endianness)
    }
}
