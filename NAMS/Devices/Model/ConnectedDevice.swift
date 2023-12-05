//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SwiftUI


@Observable
class ConnectedDevice {
    let device: EEGDevice
    var listener: DeviceConnectionListener?

    var state: ConnectionState {
        get {
            access(keyPath: \.state)
            return publishedState
        }
        set {
            withMutation(keyPath: \.state) {
                publishedState = newValue
            }
        }
    }

    @ObservationIgnored @Published var publishedState: ConnectionState = .unknown // current workaround to create a publisher for the view model

    // artifacts muse supports
    var wearingHeadband = false
    var eyeBlink = false
    var jawClench = false

    /// Determines if the last second of data is considered good
    var isGood: (Bool, Bool, Bool, Bool) = (false, false, false, false) // swiftlint:disable:this large_tuple
    /// The current fit of the headband
    var fit = HeadbandFit(tp9Fit: .poor, af7Fit: .poor, af8Fit: .poor, tp10Fit: .poor)

    var aboutInformation: OrderedDictionary<LocalizedStringResource, CustomStringConvertible> = [:]

    /// Remaining battery percentage in percent [0.0;100.0]
    var remainingBatteryPercentage: Double?

    @Binding @ObservationIgnored var session: EEGRecordingSession?

    init(device: EEGDevice, session: Binding<EEGRecordingSession?>) {
        self.device = device
        self._session = session
    }

    func connect() {
        listener = device.connect(state: self)
    }

    func disconnect() {
        device.disconnect()
        listener = nil
    }
}


extension ConnectedDevice: Hashable {
    static func == (lhs: ConnectedDevice, rhs: ConnectedDevice) -> Bool {
        lhs.device.macAddress == rhs.device.macAddress
    }

    func hash(into hasher: inout Hasher) {
        device.macAddress.hash(into: &hasher)
    }
}


extension LocalizedStringResource: Hashable {
    public static func == (lhs: LocalizedStringResource, rhs: LocalizedStringResource) -> Bool {
        lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}
