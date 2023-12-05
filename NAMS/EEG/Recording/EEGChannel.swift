//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


struct EEGChannel: RawRepresentable, Hashable {
    static let tp9 = EEGChannel(rawValue: "TP9")
    static let af7 = EEGChannel(rawValue: "AF7")
    static let af8 = EEGChannel(rawValue: "AF9")
    static let tp10 = EEGChannel(rawValue: "TP10")

    static let fp1 = EEGChannel(rawValue: "Fp1")
    static let fpz = EEGChannel(rawValue: "FpZ")
    static let fp2 = EEGChannel(rawValue: "Fp2")

    // non-standard Biopot positions
    static let lme = EEGChannel(rawValue: "LME")
    static let mm = EEGChannel(rawValue: "MM") // swiftlint:disable:this identifier_name

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
