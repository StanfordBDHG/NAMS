//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore
import SpeziBluetooth


struct DataControl {
    let dataAcquisitionEnabled: Bool

    init(dataAcquisitionEnabled: Bool) {
        self.dataAcquisitionEnabled = dataAcquisitionEnabled
    }
}


extension DataControl: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard byteBuffer.readableBytes >= 1 else {
            return nil
        }

        guard let dataAcquisitionEnabled = byteBuffer.readInteger(as: UInt8.self) else {
            return nil
        }

        self.dataAcquisitionEnabled = dataAcquisitionEnabled == 1
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        byteBuffer.reserveCapacity(1)

        byteBuffer.writeInteger(dataAcquisitionEnabled ? 1 : 0, as: UInt8.self)
    }
}
