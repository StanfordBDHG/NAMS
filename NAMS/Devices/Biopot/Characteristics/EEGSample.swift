//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import EDFFormat
import NIOCore


struct EEGSample { // we always deal with 8 channel samples
    let channels: [BDFSample]
}


extension EEGSample: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard byteBuffer.readableBytes >= 24 else {
            return nil
        }

        var channels: [BDFSample] = []
        channels.reserveCapacity(8)

        for _ in 0..<8 {
            guard let channel = BDFSample(from: &byteBuffer, preferredEndianness: endianness) else {
                return nil
            }
            channels.append(channel)
        }

        self.channels = channels
    }
}
