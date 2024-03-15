//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


@Observable
class MuseDeviceInformation {
#if MUSE
    typealias NotchFilter = IXNNotchFrequency
#else
    typealias NotchFilter = Void
#endif

#if MUSE
    static let notchDefault: NotchFilter = .notchNone
#else
    static let notchDefault: NotchFilter = ()
#endif

    let serialNumber: String
    let firmwareVersion: String
    let hardwareVersion: String

    let sampleRate: Int
    let notchFilter: NotchFilter
    /// The Analog Front-End Gain.
    let afeGain: Int

    /// Remaining battery percentage in percent [0.0;100.0]
    var remainingBatteryPercentage: Double?

    // artifacts muse supports
    var wearingHeadband = false
    var eyeBlink = false
    var jawClench = false

    /// Determines if the last second of data is considered good
    var isGood: (Bool, Bool, Bool, Bool) = (false, false, false, false) // swiftlint:disable:this large_tuple
                                                                        /// The current fit of the headband
    var fit: HeadbandFit?

    init(
        serialNumber: String,
        firmwareVersion: String,
        hardwareVersion: String,
        sampleRate: Int,
        notchFilter: NotchFilter,
        afeGain: Int,
        remainingBatteryPercentage: Double? = nil,
        wearingHeadband: Bool = false,
        fit: HeadbandFit? = nil
    ) {
        self.serialNumber = serialNumber
        self.firmwareVersion = firmwareVersion
        self.hardwareVersion = hardwareVersion
        self.sampleRate = sampleRate
        self.notchFilter = notchFilter
        self.afeGain = afeGain
        self.remainingBatteryPercentage = remainingBatteryPercentage
        self.wearingHeadband = wearingHeadband
        self.fit = fit
    }
}


extension MuseDeviceInformation {
    static func mock(
        serialNumber: String = "0xAABBCCDD",
        firmwareVersion: String = "1.0",
        hardwareVersion: String = "20.0",
        sampleRate: Int = 60,
        notchFilter: NotchFilter = MuseDeviceInformation.notchDefault,
        afeGain: Int = 2000,
        remainingBatteryPercentage: Double = 75,
        wearingHeadband: Bool = false,
        fit: HeadbandFit? = nil
    ) -> MuseDeviceInformation {
        MuseDeviceInformation(
            serialNumber: serialNumber,
            firmwareVersion: firmwareVersion,
            hardwareVersion: hardwareVersion,
            sampleRate: sampleRate,
            notchFilter: notchFilter,
            afeGain: afeGain,
            remainingBatteryPercentage: remainingBatteryPercentage,
            wearingHeadband: wearingHeadband,
            fit: fit
        )
    }
}
