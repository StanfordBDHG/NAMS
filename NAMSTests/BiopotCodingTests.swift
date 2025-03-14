//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


@_spi(TestingSupport)
import ByteCoding
@testable import NAMS
import NIOCore
import SpeziBluetooth
import XCTByteCoding
import XCTest


class BiopotCodingTests: XCTestCase {
    func testRealDeviceInformationNotCharging() throws {
        // real data we recoded from the device
        let data = try XCTUnwrap(Data(hex: "0x000000000000000000000001561c010000000000"))
        var buffer = ByteBuffer(data: data)

        let information = try XCTUnwrap(DeviceInformation(from: &buffer))

        XCTAssertEqual(information.syncRatio, 0)
        XCTAssertFalse(information.syncMode)
        XCTAssertEqual(information.memoryWriteNumber, 0)
        XCTAssertTrue(information.memoryEraseMode)
        XCTAssertEqual(information.batteryLevel, 86)
        XCTAssertEqual(information.temperatureValue, 28)
        XCTAssertFalse(information.batteryCharging)
    }

    func testRealDeviceInformationCharging() throws {
        // real data we recoded from the device
        let data = try XCTUnwrap(Data(hex: "0x000000000000000000000001561c000000000000"))
        var buffer = ByteBuffer(data: data)

        let information = try XCTUnwrap(DeviceInformation(from: &buffer))

        XCTAssertEqual(information.syncRatio, 0)
        XCTAssertFalse(information.syncMode)
        XCTAssertEqual(information.memoryWriteNumber, 0)
        XCTAssertTrue(information.memoryEraseMode)
        XCTAssertEqual(information.batteryLevel, 86)
        XCTAssertEqual(information.temperatureValue, 28)
        XCTAssertTrue(information.batteryCharging)
    }

    func testRealDeviceConfiguration() throws {
        // real data we recoded from the device
        let data = try XCTUnwrap(Data(hex: "0x0000000000080100010918010000007f"))
        var buffer = ByteBuffer(data: data)

        let information = try XCTUnwrap(DeviceConfiguration(from: &buffer))

        XCTAssertEqual(information.channelCount, 8)
        XCTAssertEqual(information.accelerometerStatus, .dynamicallySelectable2g)
        XCTAssertFalse(information.impedanceStatus)
        XCTAssertTrue(information.memoryStatus)
        XCTAssertEqual(information.samplesPerChannel, 9)
        XCTAssertEqual(information.dataSize, 24) // in bits
        XCTAssertTrue(information.syncEnabled)
        XCTAssertEqual(information.serialNumber, 127)

        // we calculate the `samplesPerChannel` ourselves as specified by the documentation
        let calculatedSamplesPerChannel: Int = (244 - 4 - 4 * (information.impedanceStatus ? 1 : 0)
                                                - 12 * (information.accelerometerStatus.rawValue > 0 ? 1 : 0))
            / (Int(information.channelCount) * (Int(information.dataSize) / 8))
        XCTAssertEqual(calculatedSamplesPerChannel, Int(information.samplesPerChannel))
    }

    func testRealDeviceConfigurationIdentity() throws {
        let data = try XCTUnwrap(Data(hex: "0x0000000000080100010918010000007f"))
        try testIdentity(of: DeviceConfiguration.self, from: data)
    }

    func testDataControlDisabled() throws {
        let data = try XCTUnwrap(Data(hex: "0x00"))
        var buffer = ByteBuffer(data: data)

        let control = try XCTUnwrap(DataControl(from: &buffer))
        XCTAssertEqual(control, .paused)

        try testIdentity(of: DataControl.self, from: data)
    }

    func testDataControlEnabled() throws {
        let data = try XCTUnwrap(Data(hex: "0x01"))
        var buffer = ByteBuffer(data: data)

        let control = try XCTUnwrap(DataControl(from: &buffer))
        XCTAssertEqual(control, .started)

        try testIdentity(of: DataControl.self, from: data)
    }

    func testDataControlStopped() throws {
        let data = try XCTUnwrap(Data(hex: "0x02"))
        var buffer = ByteBuffer(data: data)

        let control = try XCTUnwrap(DataControl(from: &buffer))
        XCTAssertEqual(control, .stopped)

        try testIdentity(of: DataControl.self, from: data)
    }

    func testSamplingConfiguration() throws {
        let data = try XCTUnwrap(Data(hex: "0x000000ff000701f40903040000"))
        var buffer = ByteBuffer(data: data)

        let configuration = try XCTUnwrap(SamplingConfiguration(from: &buffer))

        XCTAssertEqual(configuration.channelsBitMask, 0xFF) // enable channels 1-8
        XCTAssertEqual(configuration.lowPassFilter, .Hz_100) // zero
        XCTAssertEqual(configuration.highPassFilter, .Hz_2_0) // default
        XCTAssertEqual(configuration.hardwareSamplingRate, 500) // 0x01f4
        XCTAssertEqual(configuration.impedanceFrequency, 9)
        XCTAssertEqual(configuration.impedanceScale, 3)
        XCTAssertEqual(configuration.softwareLowPassFilter, .Hz_20) // default

        let idData = try XCTUnwrap(Data(hex: "0x000000ff000701f40903040000"))
        try testIdentity(of: SamplingConfiguration.self, from: idData)
    }

    func testDataAcquisition11_1() throws {
        let data = try XCTUnwrap(Data(
            hex: """
                 0x1b000000\
                 6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
                 1e35a11e35a11e35a11e35a11e35a11e35a11e35a11e35a1\
                 75c6a275c6a275c6a275c6a275c6a275c6a275c6a275c6a2\
                 ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4\
                 d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5\
                 2889a72889a72889a72889a72889a72889a72889a72889a7\
                 4e1da94e1da94e1da94e1da94e1da94e1da94e1da94e1da9\
                 1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa\
                 b63aacb63aacb63aacb63aacb63aacb63aacb63aacb63aac\
                 50fad0fe60c310fa80fe60c3
                 """
        ))
        var buffer = ByteBuffer(data: data)

        let acquisition = try XCTUnwrap(DataAcquisition11(from: &buffer))

        XCTAssertEqual(acquisition.totalSampleCount, 27)

        XCTAssertEqual(acquisition.samples.count, 9)
        XCTAssertTrue(
            acquisition.samples
                .map { $0.channels.count }
                .allSatisfy { $0 == 8 }
        )

        // we OR by 0xFF000000 for all that negative values to fix two's complement
        let expectedCH1Sample: [Int32] = [
            Int32(bitPattern: 0x9fab6a | 0xFF000000), // 6aab9f
            Int32(bitPattern: 0xa1351e | 0xFF000000), // 1e35a1
            Int32(bitPattern: 0xa2c675 | 0xFF000000), // 75c6a2
            Int32(bitPattern: 0xa45bed | 0xFF000000), // ed5ba4
            Int32(bitPattern: 0xa5f2d8 | 0xFF000000), // d8f2a5
            Int32(bitPattern: 0xa78928 | 0xFF000000), // 2889a7
            Int32(bitPattern: 0xa91d4e | 0xFF000000), // 4e1da9
            Int32(bitPattern: 0xaaae1e | 0xFF000000), // 1eaeaa
            Int32(bitPattern: 0xac3ab6 | 0xFF000000)  // b63aac
        ]

        XCTAssertEqual(acquisition.samples.compactMap { $0.channels.first?.value }, expectedCH1Sample)

        XCTAssertEqual(acquisition.accelerometerSample.point1.x, -1456)
        XCTAssertEqual(acquisition.accelerometerSample.point1.y, -304)
        XCTAssertEqual(acquisition.accelerometerSample.point1.z, -15520)

        XCTAssertEqual(acquisition.accelerometerSample.point2.x, -1520)
        XCTAssertEqual(acquisition.accelerometerSample.point2.y, -384)
        XCTAssertEqual(acquisition.accelerometerSample.point2.z, -15520)
    }

    func testDataAcquisition11_2() throws {
        let data = try XCTUnwrap(Data(
            hex: """
                 49020000\
                 6fffff6fffff6fffff6fffff6fffff6fffff6fffff6fffff\
                 72ffff72ffff72ffff72ffff72ffff72ffff72ffff72ffff\
                 75ffff75ffff75ffff75ffff75ffff75ffff75ffff75ffff\
                 78ffff78ffff78ffff78ffff78ffff78ffff78ffff78ffff\
                 7bffff7bffff7bffff7bffff7bffff7bffff7bffff7bffff\
                 7effff7effff7effff7effff7effff7effff7effff7effff\
                 81ffff81ffff81ffff81ffff81ffff81ffff81ffff81ffff\
                 84ffff84ffff84ffff84ffff84ffff84ffff84ffff84ffff\
                 87ffff87ffff87ffff87ffff87ffff87ffff87ffff87ffff\
                 f0f9a0fe70c300faa0fe90c3
                 """
        ))
        var buffer = ByteBuffer(data: data)

        let acquisition = try XCTUnwrap(DataAcquisition11(from: &buffer))

        print(acquisition)

        XCTAssertEqual(acquisition.totalSampleCount, 585)

        XCTAssertEqual(acquisition.samples.count, 9)
        XCTAssertTrue(
            acquisition.samples
                .map { $0.channels.count }
                .allSatisfy { $0 == 8 }
        )

        // we OR by 0xFF000000 for all that negative values to fix two's complement
        let expectedCH1Sample: [Int32] = [
            Int32(bitPattern: 0xffff6f | 0xFF000000), // 6fffff
            Int32(bitPattern: 0xffff72 | 0xFF000000), // 72ffff
            Int32(bitPattern: 0xffff75 | 0xFF000000), // 75ffff
            Int32(bitPattern: 0xffff78 | 0xFF000000), // 78ffff
            Int32(bitPattern: 0xffff7b | 0xFF000000), // 7bffff
            Int32(bitPattern: 0xffff7e | 0xFF000000), // 7effff
            Int32(bitPattern: 0xffff81 | 0xFF000000), // 81ffff
            Int32(bitPattern: 0xffff84 | 0xFF000000), // 84ffff
            Int32(bitPattern: 0xffff87 | 0xFF000000)  // 87ffff
        ]

        XCTAssertEqual(acquisition.samples.compactMap { $0.channels.first?.value }, expectedCH1Sample)

        XCTAssertEqual(acquisition.accelerometerSample.point1.x, -1552)
        XCTAssertEqual(acquisition.accelerometerSample.point1.y, -352)
        XCTAssertEqual(acquisition.accelerometerSample.point1.z, -15504)

        XCTAssertEqual(acquisition.accelerometerSample.point2.x, -1536)
        XCTAssertEqual(acquisition.accelerometerSample.point2.y, -352)
        XCTAssertEqual(acquisition.accelerometerSample.point2.z, -15472)
    }

    func testDataAcquisition10() throws {
        let data = try XCTUnwrap(Data(
            hex: """
                 0x1b000000\
                 6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
                 1e35a11e35a11e35a11e35a11e35a11e35a11e35a11e35a1\
                 75c6a275c6a275c6a275c6a275c6a275c6a275c6a275c6a2\
                 ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4ed5ba4\
                 d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5d8f2a5\
                 2889a72889a72889a72889a72889a72889a72889a72889a7\
                 4e1da94e1da94e1da94e1da94e1da94e1da94e1da94e1da9\
                 1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa1eaeaa\
                 b63aacb63aacb63aacb63aacb63aacb63aacb63aacb63aac\
                 87ffff87ffff87ffff87ffff87ffff87ffff87ffff87ffff
                 """
        ))
        var buffer = ByteBuffer(data: data)

        let acquisition = try XCTUnwrap(DataAcquisition10(from: &buffer))

        XCTAssertEqual(acquisition.totalSampleCount, 27)

        XCTAssertEqual(acquisition.samples.count, 10)
        XCTAssertTrue(
            acquisition.samples
                .map { $0.channels.count }
                .allSatisfy { $0 == 8 }
        )

        // we OR by 0xFF000000 for all that negative values to fix two's complement
        let expectedCH1Sample: [Int32] = [
            Int32(bitPattern: 0x9fab6a | 0xFF000000), // 6aab9f
            Int32(bitPattern: 0xa1351e | 0xFF000000), // 1e35a1
            Int32(bitPattern: 0xa2c675 | 0xFF000000), // 75c6a2
            Int32(bitPattern: 0xa45bed | 0xFF000000), // ed5ba4
            Int32(bitPattern: 0xa5f2d8 | 0xFF000000), // d8f2a5
            Int32(bitPattern: 0xa78928 | 0xFF000000), // 2889a7
            Int32(bitPattern: 0xa91d4e | 0xFF000000), // 4e1da9
            Int32(bitPattern: 0xaaae1e | 0xFF000000), // 1eaeaa
            Int32(bitPattern: 0xac3ab6 | 0xFF000000), // b63aac
            Int32(bitPattern: 0xffff87 | 0xFF000000)  // 8787ffff
        ]

        XCTAssertEqual(acquisition.samples.compactMap { $0.channels.first?.value }, expectedCH1Sample)
    }
}
