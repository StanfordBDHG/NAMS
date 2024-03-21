//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum EEGRecordingError: LocalizedError {
    case noSelectedPatient
    case noConnectedDevice
    case deviceNotReady
    case unexpectedError


    var errorDescription: String? {
        switch self {
        case .noSelectedPatient:
            String(localized: "No Patient Selected")
        case .noConnectedDevice:
            String(localized: "No Connected Device")
        case .deviceNotReady:
            String(localized: "Device Not Ready")
        case .unexpectedError:
            String(localized: "Unexpected Error")
        }
    }

    var failureReason: String? {
        switch self {
        case .noSelectedPatient:
            String(localized: "EEG recording could not be started as no patient was selected.")
        case .noConnectedDevice:
            String(localized: "EEG recording could not be started as no connected device was found.")
        case .deviceNotReady:
            String(localized: "There was an unexpected error when preparing the connected device for the recording.")
        case .unexpectedError:
            String(localized: "Unexpected error occurred while trying to start the recording. Please try again!")
        }
    }
}
