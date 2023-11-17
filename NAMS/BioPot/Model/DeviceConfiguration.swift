//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore


enum AccelerometerStatus: UInt8 {
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
    let dataSize: UInt8
    let syncEnabled: Bool
    let serialNumber: String
}


extension DeviceConfiguration {
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
              let serialNumber = byteBuffer.readString(length: 4) else { // TODO: what's the format?

            // TODO: ?? pointer[12...15] // TODO: verify that this is how it is done!
            //  .map { element in
            //      String(format: "%02hhx", element)
            //  }
            //  .joined()
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
}
