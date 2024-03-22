//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews


enum RecordingState {
    case preparing
    case inProgress
    case saving
    case fileUploadFailed(LocalizedError)
    case unrecoverableError(LocalizedError)
    case completed
}


extension RecordingState: OperationState {
    var representation: ViewState {
        switch self {
        case .preparing, .inProgress, .completed:
            .idle
        case .saving:
            .processing
        case let .fileUploadFailed(error), let .unrecoverableError(error):
            .error(error)
        }
    }
}
