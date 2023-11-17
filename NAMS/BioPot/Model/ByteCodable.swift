//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIOCore


protocol ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer)
}


protocol ByteEncodable {
    func encode(to byteBuffer: inout ByteBuffer)
}


typealias ByteCodable = ByteEncodable & ByteDecodable
