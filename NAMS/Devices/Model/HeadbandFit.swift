//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


struct HeadbandFit: Hashable {
    let tp9Fit: Fit
    let af7Fit: Fit
    let af8Fit: Fit
    let tp10Fit: Fit

    var overallFit: Fit {
        let allFits = [tp9Fit, af7Fit, af8Fit, tp10Fit]

        if allFits.filter({ $0 == .good }).count >= 3 && !allFits.contains(.poor) {
            return .good
        }

        let poorCount = allFits.filter { $0 == .poor }.count
        let mediocreCount = allFits.filter { $0 == .mediocre }.count

        if poorCount > 1 {
            return .poor
        }

        return mediocreCount >= poorCount ? .mediocre : .poor
    }

    init(tp9Fit: Fit, af7Fit: Fit, af8Fit: Fit, tp10Fit: Fit) {
        self.tp9Fit = tp9Fit
        self.af7Fit = af7Fit
        self.af8Fit = af8Fit
        self.tp10Fit = tp10Fit
    }
}
