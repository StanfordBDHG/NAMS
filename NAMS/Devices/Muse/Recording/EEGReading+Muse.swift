//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
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
