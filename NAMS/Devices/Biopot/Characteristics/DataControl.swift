//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
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


extension DataControl: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: BooleanLiteralType) {
        self.init(dataAcquisitionEnabled: value)
    }
}


extension DataControl: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let value = Bool(from: &byteBuffer) else {
            return nil
        }

        self.dataAcquisitionEnabled = value
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        dataAcquisitionEnabled.encode(to: &byteBuffer)
    }
}
