//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIOCore


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
        guard let enabled = Bool(from: &byteBuffer, endianness: .big),
              let bioEnabled = Bool(from: &byteBuffer, endianness: .big),
              let interval = UInt8(from: &byteBuffer, endianness: .big),
              let values = byteBuffer.readBytes(length: byteBuffer.readableBytes) else {
            return nil
        }

        self.init(enabled: enabled, bioImpedanceEnabled: bioEnabled, interval: interval, values: values)
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        enabled.encode(to: &byteBuffer, endianness: .big)
        bioImpedanceEnabled.encode(to: &byteBuffer, endianness: .big)
        interval.encode(to: &byteBuffer, endianness: .big)
        byteBuffer.writeBytes(values)
    }
}
