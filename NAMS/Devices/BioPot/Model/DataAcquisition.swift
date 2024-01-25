//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import SpeziBluetooth


struct DataAcquisition10: DataAcquisition {
    let timestamps: UInt32
    let samples: [EEGSample] // 10 samples
}


struct DataAcquisition11: DataAcquisition {
    let timestamps: UInt32
    let samples: [EEGSample] // 9 samples
    let accelerometerSample: AccelerometerSample
}


protocol DataAcquisition: ByteDecodable {
    /// Time from start of the recording.
    var timestamps: UInt32 { get }
    /// Array of samples. Amount depends on the type.
    var samples: [EEGSample] { get }
}


extension DataAcquisition {
    // swiftlint:disable:next discouraged_optional_collection
    fileprivate static func readSamples(from byteBuffer: inout ByteBuffer, count: Int) -> [EEGSample]? {
        var samples: [EEGSample] = []
        samples.reserveCapacity(count)

        for _ in 0 ..< count {
            guard let sample = EEGSample(from: &byteBuffer) else {
                return nil
            }
            samples.append(sample)
        }

        return samples
    }
}


extension DataAcquisition10 {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 244 else { // 244 bytes for type 10
            return nil
        }

        guard let timestamps = UInt32(from: &byteBuffer),
              let samples = Self.readSamples(from: &byteBuffer, count: 10) else {
            return nil
        }

        self.timestamps = timestamps
        self.samples = samples
    }
}


extension DataAcquisition11 {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 232 else { // 232 bytes for type 11
            return nil
        }

        guard let timestamps = UInt32(from: &byteBuffer),
              let samples = Self.readSamples(from: &byteBuffer, count: 9),
              let accelerometerSample = AccelerometerSample(from: &byteBuffer) else {
            return nil
        }

        self.timestamps = timestamps
        self.samples = samples
        self.accelerometerSample = accelerometerSample
    }
}
