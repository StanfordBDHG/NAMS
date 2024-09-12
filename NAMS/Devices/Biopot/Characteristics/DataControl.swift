//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIOCore


enum DataControl: UInt8 {
    /// Data acquisition is paused.
    case paused = 0x00
    /// Data acquisition is turned on.
    case started = 0x01
    /// Data acquisition is stopped.
    ///
    /// - Note: The semantic difference to `stopped` is not quite clear. Usually this is the initial value
    /// when connecting. However, it is never set by us (and also not by the original Biopot app).
    case stopped = 0x02
}


extension DataControl: PrimitiveByteCodable {
    init?(from byteBuffer: inout ByteBuffer, endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, endianness: endianness),
              let dataControl = DataControl(rawValue: value) else {
            return nil
        }

        self = dataControl
    }

    func encode(to byteBuffer: inout ByteBuffer, endianness: Endianness) {
        rawValue.encode(to: &byteBuffer, endianness: endianness)
    }
}
