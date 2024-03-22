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
    init?(from packet: IXNMuseDataPacket, _ location: EEGLocation) {
        let value = packet.getEegChannelValue(location.ixnEEG)

        guard value >= Double(Int32.min) && value <= Double(Int32.max) else {
            return nil
        }

        self.init(Int32(value))
    }
}
#endif
