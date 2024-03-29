//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import SpeziBluetooth


struct EEGChannelSample { // we always deal with 24-bits channel samples
    let sample: Int32
}


struct EEGSample { // we always deal with 8 channel samples
    let channels: [EEGChannelSample]
}


extension EEGChannelSample: RawRepresentable {
    var rawValue: Int32 {
        sample
    }


    init(rawValue: Int32) {
        self.init(sample: rawValue)
    }
}


extension EEGChannelSample: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 3 else {
            return nil
        }

        guard let sample = byteBuffer.read24Int(endianness: .little) else {
            return nil
        }

        self.sample = sample
    }
}


extension EEGSample: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 24 else {
            return nil
        }

        var channels: [EEGChannelSample] = []
        channels.reserveCapacity(8)

        for _ in 0..<8 {
            guard let channel = EEGChannelSample(from: &byteBuffer) else {
                return nil
            }
            channels.append(channel)
        }

        self.channels = channels
    }
}
