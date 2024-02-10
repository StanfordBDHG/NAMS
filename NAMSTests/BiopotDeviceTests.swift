//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import NAMS
@_spi(TestingSupport)
import SpeziBluetooth
import XCTest


final class BiopotDeviceTests: XCTestCase {
    private var device: BiopotDevice! // swiftlint:disable:this implicitly_unwrapped_optional

    override func setUpWithError() throws {
        self.device = BiopotDevice.createMock()
    }

    func testDataAcquisition() async throws {
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

        let configuration = DeviceConfiguration(
            channelCount: 8,
            accelerometerStatus: .off,
            impedanceStatus: false,
            memoryStatus: false,
            samplesPerChannel: 9,
            dataSize: 24,
            syncEnabled: false,
            serialNumber: 127
        )


        device.service.$deviceConfiguration.inject(configuration)
        device.service.$dataAcquisition.inject(data)

        let session = EEGRecordingSession()

        do {
            try await device.startRecording(session)
        } catch {
            // this will throw because there is no peripheral connected, but we only care about assigning the session
        }

        device.handleDataAcquisition(data: data)

        try await Task.sleep(for: .milliseconds(100))
        print(session.measurements)
        // TODO: assert measurements
    }
}
