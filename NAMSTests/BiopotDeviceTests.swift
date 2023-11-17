//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import NAMS
import Spezi
import SpeziBluetooth
import SwiftUI
import XCTest


private class TestDelegate: SpeziAppDelegate {
    let device: BiopotDevice

    override var configuration: Configuration {
        Configuration {
            Bluetooth(services: [])
            device
        }
    }


    init(device: BiopotDevice) {
        self.device = device
    }
}


final class BiopotDeviceTests: XCTestCase {
    private var device: BiopotDevice! // swiftlint:disable:this implicitly_unwrapped_optional

    override func setUpWithError() throws {
        let device = BiopotDevice()

        // this is a workaround to call the Spezi initializer here, to inject all dependencies.
        _ = EmptyView()
            .spezi(TestDelegate(device: device))

        self.device = device
    }

    @MainActor
    func testReceiveDeviceInformation() async throws {
        let data = try XCTUnwrap(Data(hex: "0x000000000000000000000001561c010000000000"))

        await device.recieve(data, service: BiopotDevice.Service.biopot, characteristic: BiopotDevice.Characteristic.biopotDeviceInfo)

        let expected = DeviceInformation(
            syncRatio: 0,
            syncMode: false,
            memoryWriteNumber: 0,
            memoryEraseMode: true,
            batteryLevel: 86,
            temperatureValue: 28,
            batteryCharging: false
        )

        XCTAssertEqual(device.deviceInfo, expected)
    }
}
