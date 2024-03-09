//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


#if MUSE
extension EEGReading {
    init(from packet: IXNMuseDataPacket, _ location: EEGLocation) {
        self.location = location
        self.value = packet.getEegChannelValue(location.ixnEEG)
    }
}
#endif
