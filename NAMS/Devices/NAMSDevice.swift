//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import EDFFormat


protocol NAMSDevice: GenericBluetoothPeripheral {
    /// The string description of the equipment used for the BDF file.
    var equipmentCode: String { get }
    /// Description of signals expected in each data record.
    var signalDescription: [Signal] { get throws }
    /// The duration of a single data record in seconds.
    var recordDuration: Int { get }

    func connect() async

    func disconnect() async

    /// Creates a new recording stream.
    ///
    /// Prepares the device for recording and enables recording for the device.
    /// Further, this method creates an async stream that yields the EEG samples received from the device.
    ///
    /// - Important: Implementation must make sure to properly stop recording on the device if the async stream is getting cancelled.
    func startRecording() async throws -> AsyncStream<CombinedEEGSample>

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void)
}
