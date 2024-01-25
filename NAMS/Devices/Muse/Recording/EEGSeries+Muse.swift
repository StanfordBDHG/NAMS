//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension EEGSeries {
    init(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType().isEEGPacket, "Unsupported packet type to parse EEG readings \(packet.packetType())")

        let epochMillis = packet.timestamp()

        self.init(
            timestamp: Date(timeIntervalSince1970: Double(epochMillis) * 0.001 * 0.001), // micro seconds -> seconds
            readings: [
                EEGReading(from: packet, .tp9),
                EEGReading(from: packet, .af7),
                EEGReading(from: packet, .af8),
                EEGReading(from: packet, .tp10)
            ]
        )
    }
}
#endif
