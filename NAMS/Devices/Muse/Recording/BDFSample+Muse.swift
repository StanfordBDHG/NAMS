//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat


#if MUSE
extension BDFSample {
    init(from packet: IXNMuseDataPacket, _ location: EEGLocation) {
        // TODO: this might crash???
        self.init(Int32(packet.getEegChannelValue(location.ixnEEG)))
    }
}
#endif
