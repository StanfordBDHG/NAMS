//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension Fit {
    init(from value: Double) {
        switch value {
        case 1.0:
            self = .good
        case 2.0:
            self = .mediocre
        case 4.0:
            self = .poor
        default:
            self = .poor
        }
    }
}


extension HeadbandFit {
    init(from packet: IXNMuseDataPacket) {
        precondition(packet.packetType() == .hsiPrecision, "Unsupported packet type to parse EEG readings \(packet.packetType())")

        self.init(
            tp9Fit: Fit(from: packet.getEegChannelValue(.EEG1)),
            af7Fit: Fit(from: packet.getEegChannelValue(.EEG2)),
            af8Fit: Fit(from: packet.getEegChannelValue(.EEG3)),
            tp10Fit: Fit(from: packet.getEegChannelValue(.EEG4))
        )
    }
}
#endif
