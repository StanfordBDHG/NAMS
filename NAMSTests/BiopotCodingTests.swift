//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import NAMS
import NIOCore
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
        try testIdentity(of: DeviceConfiguration.self, using: data)
    }
}


func testIdentity<T: ByteCodable>(of type: T.Type, using data: Data) throws {
    var decodingBuffer = ByteBuffer(data: data)

    let instance: T = try XCTUnwrap(T(from: &decodingBuffer))

    var encodingBuffer = ByteBuffer()
    encodingBuffer.reserveCapacity(data.count)

    instance.encode(to: &encodingBuffer)

    let encodingData = Data(buffer: encodingBuffer)
    XCTAssertEqual(encodingData, data)
}


extension Data {
    init?(hex: String) {
        // while this seems complicated, and you can do it with shorter code,
        // this doesn't incur any heap allocations for string. Pretty neat.

        var index = hex.startIndex

        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            index = hex.index(index, offsetBy: 2)
        }

        var bytes: [UInt8] = []
        bytes.reserveCapacity(hex.count / 2 + hex.count % 2)

        if !hex.count.isMultiple(of: 2) {
            guard let byte = UInt8(String(hex[index]), radix: 16) else {
                return nil
            }
            bytes.append(byte)

            index = hex.index(after: index)
        }


        while index < hex.endIndex {
            guard let byte = UInt8(hex[index ... hex.index(after: index)], radix: 16) else {
                return nil
            }
            bytes.append(byte)

            index = hex.index(index, offsetBy: 2)
        }

        guard hex.count / bytes.count == 2 else {
            return nil
        }
        self.init(bytes)
    }
}
