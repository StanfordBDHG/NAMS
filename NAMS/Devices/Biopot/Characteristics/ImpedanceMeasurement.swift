//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import NIO
import SpeziBluetooth


struct ImpedanceMeasurement {
    let enabled: Bool
    let bioImpedanceEnabled: Bool
    /// Impedance time in seconds between measurements
    let interval: UInt8
    /// 20 impedance values for each channel in 100Ω resolution.
    let values: [UInt8]


    init(enabled: Bool, bioImpedanceEnabled: Bool, interval: UInt8, values: [UInt8]) {
        self.enabled = enabled
        self.bioImpedanceEnabled = bioImpedanceEnabled
        self.interval = interval
        self.values = values
    }
}


extension ImpedanceMeasurement: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let enabled = Bool(from: &byteBuffer),
              let bioEnabled = Bool(from: &byteBuffer),
              let interval = UInt8(from: &byteBuffer),
              let values = byteBuffer.readBytes(length: byteBuffer.readableBytes) else {
            return nil
        }

        self.init(enabled: enabled, bioImpedanceEnabled: bioEnabled, interval: interval, values: values)
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        enabled.encode(to: &byteBuffer)
        bioImpedanceEnabled.encode(to: &byteBuffer)
        interval.encode(to: &byteBuffer)
        byteBuffer.writeBytes(values)
    }
}
