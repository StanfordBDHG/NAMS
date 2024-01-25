//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


#if MUSE
extension IXNMuseConfiguration {
    var configurationString: String {
        """
        model: \(getModel()) \
        serialNumber: \(getSerialNumber()) \
        headbandName: \(getHeadbandName()), \
        bluetoothMac: \(getBluetoothMac()) \
        batteryDataEnabled: \(getBatteryDataEnabled()) \
        batteryPercentRemaining: \(getBatteryPercentRemaining()) \
        preset: \(getPreset().description), \
        microcontrollerId: \(getMicrocontrollerId()) \
        eegChannelCount: \(getEegChannelCount()) \
        afeGain: \(getAfeGain()) \
        downsampleRate: \(getDownsampleRate()) \
        seroutMode: \(getSeroutMode()) \
        outputFrequency: \(getOutputFrequency()) \
        adcFrequency: \(getAdcFrequency()) \
        notchFilterEnabled: \(getNotchFilterEnabled()) \
        notchFilter: \(getNotchFilter().description) \
        accelerometerSampleFrequency: \(getAccelerometerSampleFrequency()) \
        drlRefEnabled: \(getDrlRefEnabled()) \
        drlRefFrequency: \(getDrlRefFrequency()) \
        licensingNonce: \(getLicenseNonce())
        """
    }
}

extension IXNNotchFrequency: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notchNone:
            return "none"
        case .notch50hz:
            return "50hz"
        case .notch60hz:
            return "60hz"
        @unknown default:
            return "UNKNOWN"
        }
    }
}
#endif
