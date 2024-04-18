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

    private let data0 = Data(
        hex: """
             0x00000000\
             0100006aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
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
    )

    private let data1 = Data(
        hex: """
             0x0a000000\
             0200006aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
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
    )

    private let data2 = Data(
        hex: """
             0x14000000\
             0300006aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
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
    )

    private let data3 = Data(
        hex: """
             0x1E000000\
             0400006aab9f6aab9f6aab9f6aab9f6aab9f6aab9f6aab9f\
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
    )

    override func setUpWithError() throws {
        self.device = BiopotDevice.createMock()
        device.service.$deviceConfiguration.inject(DeviceConfiguration(accelerometerStatus: .off, samplesPerChannel: 10))
        device.service.$dataControl.inject(.started)
    }

    func testDataAcquisition() async throws {
        let data0 = try XCTUnwrap(data0)
        let data1 = try XCTUnwrap(data1)

        // basically calling startRecording but without BLE interaction
        let stream = await device.service._makeStream()

        device.service.handleDataAcquisition(data: data0)
        device.service.handleDataAcquisition(data: data0) // tests that accidental zero packets are overwritten
        device.service.handleDataAcquisition(data: data1)

        let samples = try await collectResults(from: stream)

        XCTAssertEqual(samples.count, 20)

        let sample0 = samples[0]
        let sample10 = samples[10]
        XCTAssertEqual(sample0.channels.count, 8)
        XCTAssertEqual(sample10.channels.count, 8)

        // ensure order
        XCTAssertEqual(sample0.channels[0].value, 1)
        XCTAssertEqual(sample10.channels[0].value, 2)
    }

    func testUnorderedDataAcquisition() async throws {
        let data0 = try XCTUnwrap(data0)
        let data1 = try XCTUnwrap(data1)
        let data2 = try XCTUnwrap(data2)
        let data3 = try XCTUnwrap(data3)

        let stream = await device.service._makeStream()

        device.service.handleDataAcquisition(data: data0)
        device.service.handleDataAcquisition(data: data1)
        device.service.handleDataAcquisition(data: data3) // reorder packets
        device.service.handleDataAcquisition(data: data2)

        let samples = try await collectResults(from: stream)

        XCTAssertEqual(samples.count, 40)

        let sample0 = samples[0]
        let sample10 = samples[10]
        let sample20 = samples[20]
        let sample30 = samples[30]
        XCTAssertEqual(sample0.channels.count, 8)
        XCTAssertEqual(sample10.channels.count, 8)
        XCTAssertEqual(sample20.channels.count, 8)
        XCTAssertEqual(sample30.channels.count, 8)

        // ensure order
        XCTAssertEqual(sample0.channels[0].value, 1)
        XCTAssertEqual(sample10.channels[0].value, 2)
        XCTAssertEqual(sample20.channels[0].value, 3)
        XCTAssertEqual(sample30.channels[0].value, 4)
    }

    func testUnorderedAfterZeroDataAcquisition() async throws {
        let data0 = try XCTUnwrap(data0)
        let data1 = try XCTUnwrap(data1)
        let data2 = try XCTUnwrap(data2)
        let data3 = try XCTUnwrap(data3)

        let stream = await device.service._makeStream()

        device.service.handleDataAcquisition(data: data0)
        device.service.handleDataAcquisition(data: data2) // reorder packets
        device.service.handleDataAcquisition(data: data3)
        device.service.handleDataAcquisition(data: data1)

        let samples = try await collectResults(from: stream)

        XCTAssertEqual(samples.count, 40)

        let sample0 = samples[0]
        let sample10 = samples[10]
        let sample20 = samples[20]
        let sample30 = samples[30]
        XCTAssertEqual(sample0.channels.count, 8)
        XCTAssertEqual(sample10.channels.count, 8)
        XCTAssertEqual(sample20.channels.count, 8)
        XCTAssertEqual(sample30.channels.count, 8)

        // ensure order
        XCTAssertEqual(sample0.channels[0].value, 1)
        XCTAssertEqual(sample10.channels[0].value, 2)
        XCTAssertEqual(sample20.channels[0].value, 3)
        XCTAssertEqual(sample30.channels[0].value, 4)
    }
}


private func collectResults(
    from stream: AsyncStream<CombinedEEGSample>,
    waiting duration: Duration = .milliseconds(500)
) async throws -> [CombinedEEGSample] {
    let task = Task {
        var result: [CombinedEEGSample] = []
        for await element in stream {
            result.append(element)
        }
        return result
    }

    try await Task.sleep(for: duration)
    task.cancel() // cancel to stop recording

    return await task.value
}
