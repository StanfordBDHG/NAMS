//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIOCore


struct Point {
    let x: Int16 // swiftlint:disable:this identifier_name
    let y: Int16 // swiftlint:disable:this identifier_name
    let z: Int16 // swiftlint:disable:this identifier_name
}


struct AccelerometerSample {
    let point1: Point
    let point2: Point
}


extension Point: PrimitiveByteDecodable {
    init?(from byteBuffer: inout ByteBuffer, endianness: Endianness) {
        guard byteBuffer.readableBytes >= 6 else {
            return nil
        }

        guard let x = Int16(from: &byteBuffer, endianness: endianness), // swiftlint:disable:this identifier_name
              let y = Int16(from: &byteBuffer, endianness: endianness), // swiftlint:disable:this identifier_name
              let z = Int16(from: &byteBuffer, endianness: endianness) else { // swiftlint:disable:this identifier_name
            return nil
        }

        self.x = x
        self.y = y
        self.z = z
    }
}


extension AccelerometerSample: PrimitiveByteDecodable {
    init?(from byteBuffer: inout ByteBuffer, endianness: Endianness) {
        guard byteBuffer.readableBytes >= 12 else {
            return nil
        }

        guard let point1 = Point(from: &byteBuffer, endianness: endianness),
              let point2 = Point(from: &byteBuffer, endianness: endianness) else {
            return nil
        }

        self.point1 = point1
        self.point2 = point2
    }
}
