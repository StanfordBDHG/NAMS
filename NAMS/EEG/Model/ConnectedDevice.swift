//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


class ConnectedDevice: ObservableObject {
    let device: EEGDevice
    var listener: DeviceConnectionListener?

    @Published var state: ConnectionState = .unknown

    // artifacts muse supports
    @Published var wearingHeadband = false
    @Published var eyeBlink = false
    @Published var jawClench = false

    // swiftlint:disable:next large_tuple
    @Published var isGood: (Bool, Bool, Bool, Bool) = (false, false, false, false) // TODO type!

    /// Remaining battery percentage in percent [0.0;100.0]
    @Published var remainingBatteryPercentage: Double?

    @Published var measurements: [EEGFrequency: [EEGSeries]] = [:]

    init(device: EEGDevice) {
        self.device = device
    }

    func connect() {
        listener = device.connect(state: self)
    }

    func disconnect() {
        device.disconnect()
        listener = nil
    }
}
