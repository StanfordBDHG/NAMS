//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

#if canImport(SpeziQuestionnaire)
import SpeziQuestionnaire


#if compiler(>=6)
extension Questionnaire: @retroactive Identifiable {}
#else
extension Questionnaire: Swift.Identifiable {}
#endif
#endif
