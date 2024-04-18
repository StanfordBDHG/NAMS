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
    @Environment(\.dismiss)
    private var dismiss

    @State private var viewState: ViewState = .idle
    @Binding private var recordingState: RecordingState

    private var initialTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: EEGRecordingSession.recordingDuration) ?? "0:00"
    }

    var body: some View {
        VStack { // swiftlint:disable:this closure_body_length
            switch recordingState {
            case .preparing:
                Text("In Progress")
                    .font(.title)
                    .bold()
                Text("Remaining: \(initialTime)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .bold()
            case let .inProgress(recordingTime):
                Text("In Progress")
                    .font(.title)
                    .bold()
                Text("Remaining: \(Text(timerInterval: recordingTime))")
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
                        HStack {
                            Text("Completed")
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .symbolRenderingMode(.hierarchical)
                                .accessibilityHidden(true)
                        }
                    }
                }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .bold()
            case .fileUploadFailed, .taskUploadFailed: // retry-able error states
                Text("Upload Failed")
                    .font(.title)
                    .bold()

                HStack {
                    Text("Failed to upload recording")
                    Image(systemName: "externaldrive.fill.badge.exclamationmark")
                        .foregroundColor(.red)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .bold()
            case .unrecoverableError:
                Text("Recording Failed")
                    .font(.title)
                    .bold()
                    .map(state: recordingState, to: $viewState)
                    .viewStateAlert(state: $viewState)
                    .onChange(of: viewState) { oldValue, _ in
                        if case .error = oldValue {
                            dismiss() // alert got dismissed
                        }
                    }
            }
        }
            .multilineTextAlignment(.center)
            .padding(.bottom)
    }


    init(recordingState: Binding<RecordingState>) {
        self._recordingState = recordingState
    }
}


#if DEBUG
#Preview {
    RecordingStateHeader(recordingState: .constant(.preparing))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.inProgress(duration: Date()...Date().addingTimeInterval(2 * 60))))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.saving))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.completed))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.fileUploadFailed(AnyLocalizedError(error: CancellationError()))))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.taskUploadFailed(AnyLocalizedError(error: CancellationError()))))
}

#Preview {
    RecordingStateHeader(recordingState: .constant(.unrecoverableError(AnyLocalizedError(error: CancellationError()))))
}
#endif
