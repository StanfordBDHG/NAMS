//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


struct HeadbandFit: Hashable {
    let tp9Fit: Fit
    let af7Fit: Fit
    let af8Fit: Fit
    let tp10Fit: Fit


    init(tp9Fit: Fit, af7Fit: Fit, af8Fit: Fit, tp10Fit: Fit) {
        self.tp9Fit = tp9Fit
        self.af7Fit = af7Fit
        self.af8Fit = af8Fit
        self.tp10Fit = tp10Fit
    }
}
