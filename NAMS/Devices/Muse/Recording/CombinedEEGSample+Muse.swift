//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


#if MUSE
extension CombinedEEGSample {
    init?(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType().isEEGPacket, "Unsupported packet type to parse EEG readings \(packet.packetType())")

        guard let tp9 = BDFSample(from: packet, .tp9),
              let af7 = BDFSample(from: packet, .af7),
              let af8 = BDFSample(from: packet, .af8),
              let tp10 = BDFSample(from: packet, .tp10) else {
            return nil
        }


        self.init(channels: [
            tp9,
            af7,
            af8,
            tp10
        ])
    }
}
#endif
