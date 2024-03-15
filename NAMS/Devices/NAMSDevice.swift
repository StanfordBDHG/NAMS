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

    func prepareRecording() async throws

    func startRecording(_ session: EEGRecordingSession) async throws

    func stopRecording() async throws

    @MainActor
    func setupDisconnectHandler(_ handler: @escaping @MainActor (ConnectedDevice) -> Void)
}
