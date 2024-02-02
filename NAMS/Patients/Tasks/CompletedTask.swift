//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestoreSwift
#if !VISION
import SpeziQuestionnaire
#endif


enum TaskContent {
    #if !VISION
    case questionnaireResponse(_ response: QuestionnaireResponse)
    #endif
    case eegRecording // currently empty
}


struct CompletedTask: Codable {
    @DocumentID var id: String?
    let taskId: String
    let content: TaskContent
}


extension TaskContent: Codable { // TODO: this codable conformance breaks with visionOs? is that a big deal?
    private enum CodingKeys: String, CodingKey {
        case type
        case questionnaireResponse
        case eegRecording
    }

    private enum TaskContentDecodingError: Error {
        case unknownType(_ type: String)
    }

    private static let questionnaireResponseType = "questionnaireResponse"
    private static let eegRecordingType = "eegRecording"

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)
        switch type {
        #if !VISION
        case Self.questionnaireResponseType:
            let response = try container.decode(QuestionnaireResponse.self, forKey: .questionnaireResponse)
            self = .questionnaireResponse(response)
        #endif
        case Self.eegRecordingType:
            self = .eegRecording
        default:
            throw TaskContentDecodingError.unknownType(type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        #if !VISION
        case let .questionnaireResponse(response):
            try container.encode(Self.questionnaireResponseType, forKey: .type)
            try container.encode(response, forKey: .questionnaireResponse)
        #endif
        case .eegRecording:
            try container.encode(Self.eegRecordingType, forKey: .type)
            // nothing to encode yet
        }
    }
}
