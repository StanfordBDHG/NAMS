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
    func testDeviceInformationDecoding() throws {
        // TODO: use real value
        // TODO: double?
        let data = try XCTUnwrap(Data(hex: "0x0000000000000000000000014c1701"))
        var buffer = ByteBuffer(data: data)

        let information = try XCTUnwrap(DeviceInformation(from: &buffer))

        // TODO: use values that are non zero? Endianness for uint16?
        XCTAssertEqual(information.syncRatio, 0)
        XCTAssertEqual(information.syncMode, false)
        XCTAssertEqual(information.memoryWriteNumber, 0)
        XCTAssertEqual(information.memoryEraseMode, true)
        XCTAssertEqual(information.batteryLevel, 76)
        XCTAssertEqual(information.temperatureValue, 23)
        XCTAssertEqual(information.batteryCharging, false)
    }
}


extension Data {
    init?(hex: String) {
        // while this seems complicated, and you can do it with shorter code,
        // this doesn't incur a single heap allocation. Pretty neat.
        // TODO: verify?

        var index = hex.startIndex

        if hex.hasPrefix("0x") { // TODO casing
            index = hex.index(index, offsetBy: 2)
        }

        var bytes: [UInt8] = []
        bytes.reserveCapacity(hex.count / 2) // TODO: address calulation

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
