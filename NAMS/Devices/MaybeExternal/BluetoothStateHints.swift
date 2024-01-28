//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SwiftUI


struct BluetoothStateHints: View {
    private let state: BluetoothState


    private var titleMessage: LocalizedStringResource? {
        switch state {
        case .poweredOn:
            nil
        case .poweredOff:
            "Bluetooth Off"
        case .unauthorized:
            "Bluetooth Prohibited"
        case .unsupported:
            "Bluetooth Unsupported"
        case .unknown:
            "Bluetooth Failure"
        }
    }

    private var subtitleMessage: LocalizedStringResource? {
        switch state {
        case .poweredOn:
            nil
        case .poweredOff:
            "BLUETOOTH_OFF_HINT"
        case .unauthorized:
            "BLUETOOTH_PROHIBITED_HINT"
        case .unknown:
            "BLUETOOTH_UNKNOWN"
        case .unsupported:
            "BLUETOOTH_UNSUPPORTED"
        }
    }


    var body: some View {
        if titleMessage != nil || subtitleMessage != nil {
            VStack {
                if let titleMessage {
                    Text(titleMessage)
                        .bold()
                        .font(.title2)
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)
                }

                if let subtitleMessage {
                    Text(subtitleMessage)
                        .multilineTextAlignment(.center)
                }
            }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: -15, leading: 0, bottom: 0, trailing: 0))
                .padding([.top, .leading, .trailing])
                .frame(maxWidth: .infinity)
        } else {
            EmptyView()
        }
    }


    init(state: BluetoothState) {
        self.state = state
    }
}


#if DEBUG
#Preview {
    List {
        BluetoothStateHints(state: .poweredOff)
    }
}

#Preview {
    List {
        BluetoothStateHints(state: .unauthorized)
    }
}

#Preview {
    List {
        BluetoothStateHints(state: .unsupported)
    }
}

#Preview {
    List {
        BluetoothStateHints(state: .unknown)
    }
}
#endif
