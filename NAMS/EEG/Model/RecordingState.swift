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
    case inProgress(duration: ClosedRange<Date>)
    case saving
    case fileUploadFailed(LocalizedError)
    case taskUploadFailed(LocalizedError)
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
        case let .fileUploadFailed(error), let .unrecoverableError(error), let .taskUploadFailed(error):
            .error(error)
        }
    }
}
