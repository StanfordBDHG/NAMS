//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct RecordingStateHeader: View {
    @Binding private var recordingState: RecordingState
    private let recordingTime: ClosedRange<Date>

    var body: some View {
        // TODO: swiftlint?
        VStack { // swiftlint:disable:this closure_body_length
            switch recordingState {
            case .preparing:
                Text("In Progress")
                    .font(.title)
                    .bold()
                Text("Remaining: \("2:00")") // TODO: how to handle switch to inProgress?
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .bold()
            case .inProgress:
                Text("In Progress")
                    .font(.title)
                    .bold()
                Text("Remaining: \(Text(timerInterval: recordingTime))") // TODO: only countdown if applicable?
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .bold()
            case .saving, .completed:
                Text("Recording Finished")
                    .font(.title)
                    .bold()
                Group {
                    if case .saving = recordingState {
                        Text("Saving ...")
                    } else {
                        Text("Completed") // TODO: hit done button or something?
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .bold()
            case let .fileUploadFailed(error): // TODO: display error?
                Text("Upload Failed")
                    .font(.title)
                    .bold()
                // TODO: error message below?

                Button("Try again") {
                    // TODO:
                }
            case let .unrecoverableError(error):
                Text("Recording Failed")
                    .font(.title)
                    .bold()
                    .viewStateAlert(state: recordingState)

                // TODO: some subtitle?
                // TODO: this should pop open a view alert!
            }
        }
        .multilineTextAlignment(.center)
        .padding(.bottom)
        .toolbar {
            if case .processing = recordingState.representation {
                // TODO: technically we could just add the progress state from firebase here?
                ToolbarItem(placement: .primaryAction) {
                    ProgressView() // TODO: only if actually saving?
                }
            }
        }
    }


    init(recordingState: Binding<RecordingState>, recordingTime: ClosedRange<Date>) {
        self._recordingState = recordingState
        self.recordingTime = recordingTime
    }
}



#if DEBUG
#Preview {
    RecordingStateHeader(recordingState: .constant(.preparing), recordingTime: Date()...Date())
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.inProgress), recordingTime: Date()...Date().addingTimeInterval(2 * 60 ))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.saving), recordingTime: Date()...Date())
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.completed), recordingTime: Date()...Date())
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.fileUploadFailed(AnyLocalizedError(error: CancellationError()))), recordingTime: Date()...Date())
}

#Preview {
    RecordingStateHeader(
        recordingState: .constant(.unrecoverableError(AnyLocalizedError(error: CancellationError()))),
        recordingTime: Date()...Date()
    )
}
#endif
