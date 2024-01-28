//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import SpeziBluetooth


struct Point {
    let x: Int16 // swiftlint:disable:this identifier_name
    let y: Int16 // swiftlint:disable:this identifier_name
    let z: Int16 // swiftlint:disable:this identifier_name
}


struct AccelerometerSample {
    let point1: Point
    let point2: Point
}


extension Point: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 6 else {
            return nil
        }

        guard let x = Int16(from: &byteBuffer), // swiftlint:disable:this identifier_name
              let y = Int16(from: &byteBuffer), // swiftlint:disable:this identifier_name
              let z = Int16(from: &byteBuffer) else { // swiftlint:disable:this identifier_name
            return nil
        }

        self.x = x
        self.y = y
        self.z = z
    }
}


extension AccelerometerSample: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 12 else {
            return nil
        }

        guard let point1 = Point(from: &byteBuffer),
              let point2 = Point(from: &byteBuffer) else {
            return nil
        }

        self.point1 = point1
        self.point2 = point2
    }
}
