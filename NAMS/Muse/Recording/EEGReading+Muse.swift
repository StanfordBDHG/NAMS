//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if MUSE
extension EEGReading {
    init(from packet: IXNMuseDataPacket, _ channel: EEGChannel) {
        self.channel = channel
        self.value = packet.getEegChannelValue(channel.ixnEEG)
    }
}
#endif
