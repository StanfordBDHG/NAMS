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


enum SomeDataAcquisition {
    case type10(_ acquisition: DataAcquisition10)
    case type11(_ acquisition: DataAcquisition11)
}


struct DataAcquisition10: DataAcquisition {
    let totalSampleCount: UInt32
    let samples: [BiopotSample] // 10 samples
}


struct DataAcquisition11: DataAcquisition {
    let totalSampleCount: UInt32
    let samples: [BiopotSample] // 9 samples
    let accelerometerSample: AccelerometerSample
}


private protocol DataAcquisition: Identifiable, Hashable, Comparable {
    /// The amount of total samples preceding this packet.
    var totalSampleCount: UInt32 { get }
    /// Array of samples. Amount depends on the type.
    var samples: [BiopotSample] { get }
}


extension DataAcquisition {
    var id: UInt32 {
        totalSampleCount
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.totalSampleCount == rhs.totalSampleCount
    }


    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.totalSampleCount < rhs.totalSampleCount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension DataAcquisition {
    // swiftlint:disable:next discouraged_optional_collection
    fileprivate static func readSamples(from buffer: inout ByteBuffer, count: Int) -> [BiopotSample]? {
        var samples: [BiopotSample] = []
        samples.reserveCapacity(count)

        for _ in 0 ..< count {
            guard let sample = BiopotSample(from: &buffer) else {
                return nil
            }
            samples.append(sample)
        }

        return samples
    }
}


extension SomeDataAcquisition: DataAcquisition {
    @inlinable var totalSampleCount: UInt32 {
        switch self {
        case let .type10(acquisition):
            acquisition.totalSampleCount
        case let .type11(acquisition):
            acquisition.totalSampleCount
        }
    }
    
    @inlinable var samples: [BiopotSample] {
        switch self {
        case let .type10(acquisition):
            acquisition.samples
        case let .type11(acquisition):
            acquisition.samples
        }
    }
}


extension DataAcquisition10: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 244 else { // 244 bytes for type 10
            return nil
        }

        guard let totalSampleCount = UInt32(from: &byteBuffer),
              let samples = Self.readSamples(from: &byteBuffer, count: 10) else {
            return nil
        }

        self.totalSampleCount = totalSampleCount
        self.samples = samples
    }
}


extension DataAcquisition11: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 232 else { // 232 bytes for type 11
            return nil
        }

        guard let totalSampleCount = UInt32(from: &byteBuffer),
              let samples = Self.readSamples(from: &byteBuffer, count: 9),
              let accelerometerSample = AccelerometerSample(from: &byteBuffer, endianness: .little) else {
            return nil
        }

        self.totalSampleCount = totalSampleCount
        self.samples = samples
        self.accelerometerSample = accelerometerSample
    }
}
