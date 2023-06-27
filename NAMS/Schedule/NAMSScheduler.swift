//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SpeziScheduler


/// A `Scheduler` using the `FHIR` standard as well as the ``NAMSTaskContext`` to schedule and manage tasks and events in the
/// Neurodevelopment Assessment and Monitoring System (NAMS).
typealias NAMSScheduler = Scheduler<FHIR, NAMSTaskContext>


extension NAMSScheduler {
    /// Creates a default instance of the ``NAMSScheduler`` by scheduling the tasks listed below.
    convenience init() {
        var tasks = [
            Task(
                title: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_TITLE"),
                description: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_DESCRIPTION"),
                schedule: Schedule(
                    start: Calendar.current.startOfDay(for: Date()),
                    repetition: .matching(.init(hour: 6, minute: 0)), // Every Day at 8:00 AM
                    end: .numberOfEvents(365)
                ),
                context: NAMSTaskContext.questionnaire(Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire"))
            )
        ]

        /// Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
        if FeatureFlags.testSchedule {
            let currentDate = Date.now
            let currentHour = Calendar.current.component(.hour, from: currentDate)
            let currentMinute = Calendar.current.component(.minute, from: currentDate)

            let testTask = Task(
                title: String(localized: "TASK_TEST_TITLE"),
                description: String(localized: "TASK_TEST_DESCRIPTION"),
                schedule: Schedule(
                    start: Calendar.current.startOfDay(for: currentDate),
                    repetition: .matching(.init(hour: currentHour, minute: currentMinute)), // repeat at current time
                    end: .numberOfEvents(1)
                ),
                context: NAMSTaskContext.test(String(localized: "TASK_TEST_CONTENT"))
            )
            tasks.append(testTask)
        }

        self.init(tasks: tasks)
    }
}
