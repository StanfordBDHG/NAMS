//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziViews
import SwiftUI


public protocol GenericBluetoothPeripheral {
    var label: String { get }

    var accessibilityLabel: String { get }

    var state: PeripheralState { get }

    var requiresUserAttention: Bool { get }
}


extension GenericBluetoothPeripheral {
    public var accessibilityLabel: String {
        label
    }

    public var requiresUserAttention: Bool {
        false
    }
}


struct MockBluetoothDevice: GenericBluetoothPeripheral {
    var label: String
    var state: PeripheralState
    var requiresUserAttention: Bool

    init(label: String, state: PeripheralState, requiresUserAttention: Bool = false) {
        self.label = label
        self.state = state
        self.requiresUserAttention = requiresUserAttention
    }
}


public struct NearbyDeviceRow: View {
    private let peripheral: any GenericBluetoothPeripheral
    private let devicePrimaryActionClosure: () -> Void
    private let secondaryActionClosure: (() -> Void)?


    var localizationSecondaryLabel: LocalizedStringResource? {
        if peripheral.requiresUserAttention {
            return "Intervention Required"
        }
        switch peripheral.state {
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting"
        case .disconnected:
            return nil
        }
    }

    public var body: some View {
        let stack = HStack {
            Button(action: devicePrimaryAction) {
                HStack {
                    ListRow(verbatim: peripheral.label) {
                        deviceSecondaryLabel
                    }
                    if peripheral.state == .connecting || peripheral.state == .disconnecting {
                        ProgressView()
                            .accessibilityRemoveTraits(.updatesFrequently)
                    }
                }
            }
                // .frame(maxWidth: .infinity) // required for UI tests // TODO: does this break stuff? yes breaks visuals?

            if secondaryActionClosure != nil, case .connected = peripheral.state {
                Button("DEVICE_DETAILS", systemImage: "info.circle", action: deviceDetailsAction)
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .buttonStyle(.plain) // ensure button is clickable next to the other button
                    .foregroundColor(.accentColor)
            }
        }

        #if TEST
        // accessibility actions cannot be unit tested
        stack
        #else
        stack.accessibilityRepresentation {
            accessibilityRepresentation
        }
        #endif
    }

    @ViewBuilder var accessibilityRepresentation: some View {
        let button = Button(action: devicePrimaryAction) {
            Text(verbatim: peripheral.accessibilityLabel)
            if let localizationSecondaryLabel {
                Text(localizationSecondaryLabel)
            }
        }

        if secondaryActionClosure != nil {
            button
                .accessibilityAction(named: "DEVICE_DETAILS", deviceDetailsAction)
        } else {
            button
        }
    }

    @ViewBuilder var deviceSecondaryLabel: some View {
        if peripheral.requiresUserAttention {
            Text("Requires Attention")
        } else {
            switch peripheral.state {
            case .connecting, .disconnecting:
                EmptyView()
            case .connected:
                Text("Connected")
            case .disconnected:
                EmptyView()
            }
        }
    }


    public init(
        peripheral: any GenericBluetoothPeripheral,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.peripheral = peripheral
        self.devicePrimaryActionClosure = primaryAction
        self.secondaryActionClosure = secondaryAction
    }


    private func devicePrimaryAction() {
        devicePrimaryActionClosure()
    }

    private func deviceDetailsAction() {
        if let secondaryActionClosure {
            secondaryActionClosure()
        }
    }
}


#if DEBUG
#Preview {
    List {
        NearbyDeviceRow(peripheral: MockBluetoothDevice(label: "MyDevice 1", state: .connecting)) {
            print("Clicked")
        } secondaryAction: {
        }
        NearbyDeviceRow(peripheral: MockBluetoothDevice(label: "MyDevice 2", state: .connected)) {
            print("Clicked")
        } secondaryAction: {
        }
        NearbyDeviceRow(peripheral: MockBluetoothDevice(label: "Long MyDevice 3", state: .connected, requiresUserAttention: true)) {
            print("Clicked")
        } secondaryAction: {
        }
        NearbyDeviceRow(peripheral: MockBluetoothDevice(label: "MyDevice 4", state: .disconnecting)) {
            print("Clicked")
        } secondaryAction: {
        }
    }
}
#endif
