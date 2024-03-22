//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import EDFFormat
import NIOCore


struct SamplingConfiguration {
    /// Channel off/on bits. Only used with 16-bit. Not used with 24-bit configuration.
    let channelsBitMask: UInt32
    /// Hardware low-pass filter. Not used with 24-bit configuration.
    let lowPassFilter: LowPassFilter
    /// High pass filter (Hardware for 16-bit configuration; Software for 24-bit configuration)
    let highPassFilter: HighPassFilter
    /// 500 (default) / 1000 / 2000
    let hardwareSamplingRate: UInt16
    /// Not used with 24 bits.
    let impedanceFrequency: UInt8
    let impedanceScale: UInt8
    let softwareLowPassFilter: SoftwareLowPassFilter


    init(
        channelsBitMask: UInt32 = 255, // by default enable all 8 channels
        lowPassFilter: LowPassFilter = .Hz_100,
        highPassFilter: HighPassFilter = .Hz_2_0,
        hardwareSamplingRate: UInt16 = 500,
        impedanceFrequency: UInt8 = 9,
        impedanceScale: UInt8 = 3,
        softwareLowPassFilter: SoftwareLowPassFilter = .Hz_20
    ) {
        self.channelsBitMask = channelsBitMask
        self.lowPassFilter = lowPassFilter
        self.highPassFilter = highPassFilter
        self.hardwareSamplingRate = hardwareSamplingRate
        self.impedanceFrequency = impedanceFrequency
        self.impedanceScale = impedanceScale
        self.softwareLowPassFilter = softwareLowPassFilter
    }
}


// swiftlint:disable identifier_name
extension SamplingConfiguration {
    enum LowPassFilter: UInt8 {
        case Hz_100 = 0
        case Hz_150 = 1
        case Hz_200 = 2
        case Hz_250 = 3
        case Hz_300 = 4
        case Hz_500 = 5
        case Hz_750 = 6
        case kHz_1_0 = 7
        case kHz_1_5 = 8
        case kHz_2_0 = 9
        case kHz_2_5 = 10
        case kHz_3_0 = 11
        case kHz_5_0 = 12
        case kHz_7_5 = 13
        case kHz_10 = 14
        case kHz_15 = 15
        case kHz_20 = 16
    }


    enum HighPassFilter: UInt8 {
        case Hz_0_10 = 0
        case Hz_0_25 = 1
        case Hz_0_30 = 2
        case Hz_0_50 = 3
        case Hz_0_75 = 4
        case Hz_1_0 = 5
        case Hz_1_5 = 6
        case Hz_2_0 = 7 // default
        case Hz_2_5 = 8
        case Hz_3_0 = 9
        case Hz_5_0 = 10
        case Hz_7_5 = 11
        case Hz_10 = 12
        case Hz_15 = 13
        case Hz_20 = 14
        case Hz_25 = 15
        case Hz_30 = 16
        case Hz_50 = 17
        case Hz_75 = 18
        case Hz_100 = 19
        case Hz_150 = 20
        case Hz_200 = 21
        case Hz_250 = 22
        case Hz_300 = 23
        case Hz_500 = 24
    }


    enum SoftwareLowPassFilter: UInt8 {
        case disabled = 0
        case Hz_5 = 1
        case Hz_10 = 2
        case Hz_15 = 3
        case Hz_20 = 4 // default
        case Hz_25 = 5
        case Hz_30 = 6
        case Hz_35 = 7
        case Hz_40 = 8
        case Hz_45 = 9
        case Hz_50 = 10
        case Hz_55 = 11
        case Hz_60 = 12
        case Hz_65 = 13
        case Hz_70 = 14
        case Hz_75 = 15
        case Hz_80 = 16
        case Hz_85 = 17
        case Hz_90 = 18
        case Hz_95 = 19
        case Hz_100 = 20
    }
}
// swiftlint:enable identifier_name


extension SamplingConfiguration.LowPassFilter: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }

    func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        rawValue.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}


extension SamplingConfiguration.HighPassFilter: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }

    func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        rawValue.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}


extension SamplingConfiguration.SoftwareLowPassFilter: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }

    func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        rawValue.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}


extension SamplingConfiguration: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        let endianness: Endianness = .big // we force big endianness for this type

        guard let channelsBitMask = UInt32(from: &byteBuffer, preferredEndianness: endianness),
              let lowPassFilter = LowPassFilter(from: &byteBuffer, preferredEndianness: endianness),
              let highPassFilter = HighPassFilter(from: &byteBuffer, preferredEndianness: endianness),
              let hardwareSamplingRate = UInt16(from: &byteBuffer, preferredEndianness: endianness),
              let impedanceFrequency = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let impedanceScale = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let softwareLowPassFilter = SoftwareLowPassFilter(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }

        self.channelsBitMask = channelsBitMask
        self.lowPassFilter = lowPassFilter
        self.highPassFilter = highPassFilter
        self.hardwareSamplingRate = hardwareSamplingRate
        self.impedanceFrequency = impedanceFrequency
        self.impedanceScale = impedanceScale
        self.softwareLowPassFilter = softwareLowPassFilter
    }

    func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        byteBuffer.reserveCapacity(10)

        let endianness: Endianness = .big // we force big endianness for this type

        channelsBitMask.encode(to: &byteBuffer, preferredEndianness: endianness)
        lowPassFilter.encode(to: &byteBuffer, preferredEndianness: endianness)
        highPassFilter.encode(to: &byteBuffer, preferredEndianness: endianness)
        hardwareSamplingRate.encode(to: &byteBuffer, preferredEndianness: endianness)
        impedanceFrequency.encode(to: &byteBuffer, preferredEndianness: endianness)
        impedanceScale.encode(to: &byteBuffer, preferredEndianness: endianness)
        softwareLowPassFilter.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}


extension SamplingConfiguration.HighPassFilter {
    var edfString: String {
        switch self {
        case .Hz_0_10:
            "0.1Hz"
        case .Hz_0_25:
            "0.25Hz"
        case .Hz_0_30:
            "0.3Hz"
        case .Hz_0_50:
            "0.5Hz"
        case .Hz_0_75:
            "0.75Hz"
        case .Hz_1_0:
            "1.0Hz"
        case .Hz_1_5:
            "1.5Hz"
        case .Hz_2_0:
            "2.0Hz"
        case .Hz_2_5:
            "2.5Hz"
        case .Hz_3_0:
            "3.0Hz"
        case .Hz_5_0:
            "5.0Hz"
        case .Hz_7_5:
            "7.5Hz"
        case .Hz_10:
            "10Hz"
        case .Hz_15:
            "15Hz"
        case .Hz_20:
            "20Hz"
        case .Hz_25:
            "25Hz"
        case .Hz_30:
            "30Hz"
        case .Hz_50:
            "50Hz"
        case .Hz_75:
            "75Hz"
        case .Hz_100:
            "100Hz"
        case .Hz_150:
            "150Hz"
        case .Hz_200:
            "200Hz"
        case .Hz_250:
            "250Hz"
        case .Hz_300:
            "300Hz"
        case .Hz_500:
            "500Hz"
        }
    }
}

extension SamplingConfiguration.SoftwareLowPassFilter {
    var edfString: String? {
        switch self {
        case .disabled:
            nil
        case .Hz_5:
            "5Hz"
        case .Hz_10:
            "10Hz"
        case .Hz_15:
            "15Hz"
        case .Hz_20:
            "20Hz"
        case .Hz_25:
            "25Hz"
        case .Hz_30:
            "30Hz"
        case .Hz_35:
            "35Hz"
        case .Hz_40:
            "40Hz"
        case .Hz_45:
            "45Hz"
        case .Hz_50:
            "50Hz"
        case .Hz_55:
            "55Hz"
        case .Hz_60:
            "60Hz"
        case .Hz_65:
            "65Hz"
        case .Hz_70:
            "70Hz"
        case .Hz_75:
            "75Hz"
        case .Hz_80:
            "80Hz"
        case .Hz_85:
            "85Hz"
        case .Hz_90:
            "90Hz"
        case .Hz_95:
            "95Hz"
        case .Hz_100:
            "100Hz"
        }
    }
}
