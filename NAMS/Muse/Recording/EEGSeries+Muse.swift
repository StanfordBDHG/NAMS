//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension EEGSeries {
    init(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType() == .eeg, "Unsupported packet type to parse eeg readings \(packet.packetType())") // TODO support all the other eeg packets!

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
