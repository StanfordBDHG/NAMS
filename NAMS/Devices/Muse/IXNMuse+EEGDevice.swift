//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if MUSE
extension IXNMuse: EEGDevice {
    var name: String {
        getName().replacingOccurrences(of: "Muse-", with: "")
    }

    var macAddress: String {
        getMacAddress()
    }

    var model: String {
        getModel().description
    }

    var connectionState: ConnectionState {
        ConnectionState(from: getConnectionState())
    }

    var rssi: Double {
        getRssi()
    }

    var lastDiscoveredTime: Double {
        getLastDiscoveredTime()
    }


    func connect(state device: ConnectedDevice) -> DeviceConnectionListener {
        let listener = MuseConnectionListener(muse: self, device: device)
        listener.connect()
        return listener
    }
}
#endif
