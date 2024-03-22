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
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let enabled = Bool(from: &byteBuffer, preferredEndianness: endianness),
              let bioEnabled = Bool(from: &byteBuffer, preferredEndianness: endianness),
              let interval = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let values = byteBuffer.readBytes(length: byteBuffer.readableBytes) else {
            return nil
        }

        self.init(enabled: enabled, bioImpedanceEnabled: bioEnabled, interval: interval, values: values)
    }

    func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        enabled.encode(to: &byteBuffer, preferredEndianness: endianness)
        bioImpedanceEnabled.encode(to: &byteBuffer, preferredEndianness: endianness)
        interval.encode(to: &byteBuffer, preferredEndianness: endianness)
        byteBuffer.writeBytes(values)
    }
}
