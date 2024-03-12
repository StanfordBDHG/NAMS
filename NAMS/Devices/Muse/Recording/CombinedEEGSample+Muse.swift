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
    init(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType().isEEGPacket, "Unsupported packet type to parse EEG readings \(packet.packetType())")

        let epochMillis = packet.timestamp() // TODO: Muse has exact timestamps!
        // TODO: are these sorted?

        self.init(channels: [
            BDFSample(from: packet, .tp9),
            BDFSample(from: packet, .af7),
            BDFSample(from: packet, .af8),
            BDFSample(from: packet, .tp10)
        ])
    }
}
#endif
