//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension IXNMuseVersion {
    var versionString: String {
        """
        firmware: \(getFirmwareVersion()) (\(getFirmwareBuildNumber()), \(getFirmwareType())), \
        hardware: \(getHardwareVersion()), \
        protocol: \(getProtocolVersion()), \
        bsp: \(getBspVersion()), \
        bootloaderVersion: \(getBootloaderVersion()), \
        runningState: \(getRunningState())
        """
    }
}
#endif
