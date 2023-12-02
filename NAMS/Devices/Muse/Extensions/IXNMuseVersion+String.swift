//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
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
        bsp: \(getBspVersion()) \
        bootloaderVersion: \(getBootloaderVersion()) \
        runningState: \(getRunningState())
        """
    }
}
#endif
