//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import NIOCore

extension ByteBuffer {
    @inlinable
    func get24Int(at index: Int, endianness: Endianness = .big) -> Int32? {
        guard var bitPattern = get24UInt(at: index, endianness: endianness) else {
            return nil
        }

        // what this method is doing here, is translating the 24-bit two's complement into a 32-bit two's complement.

        // if its larger than the largest positive number, we want to make sure that all upper 8 bits are flipped to one.
        if bitPattern > 0x7FFFFF { // (2 ^ 23) - 1
            bitPattern |= 0xFF000000
        }

        // I love Swift for that! We can just reinterpret the 32UInt bit pattern into a Int32!
        return Int32(bitPattern: bitPattern)
    }

    @inlinable
    mutating func read24Int(endianness: Endianness = .big) -> Int32? {
        guard let value = get24Int(at: self.readerIndex, endianness: endianness) else {
            return nil
        }
        self.moveReaderIndex(forwardBy: 3)
        return value
    }
}


// see https://github.com/apple/swift-nio-extras/pull/114
extension ByteBuffer {
    @inlinable
    func get24UInt(at index: Int, endianness: Endianness = .big) -> UInt32? {
        let mostSignificant: UInt16
        let leastSignificant: UInt8
        switch endianness {
        case .big:
            guard let uint16 = self.getInteger(at: index, endianness: .big, as: UInt16.self),
                  let uint8 = self.getInteger(at: index + 2, endianness: .big, as: UInt8.self) else { return nil }
            mostSignificant = uint16
            leastSignificant = uint8
        case .little:
            guard let uint8 = self.getInteger(at: index, endianness: .little, as: UInt8.self),
                  let uint16 = self.getInteger(at: index + 1, endianness: .little, as: UInt16.self) else { return nil }
            mostSignificant = uint16
            leastSignificant = uint8
        }
        return (UInt32(mostSignificant) << 8) &+ UInt32(leastSignificant)
    }

    @inlinable
    mutating func read24UInt(endianness: Endianness = .big) -> UInt32? {
        guard let integer = get24UInt(at: self.readerIndex, endianness: endianness) else {
            return nil
        }
        self.moveReaderIndex(forwardBy: 3)
        return integer
    }
}
