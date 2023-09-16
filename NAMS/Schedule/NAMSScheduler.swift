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


/// A `Scheduler` using the ``NAMSTaskContext`` to schedule and manage tasks and events in the
/// Neurodevelopment Assessment and Monitoring System (NAMS).
typealias NAMSScheduler = Scheduler<NAMSTaskContext>


extension NAMSScheduler {
    static var socialSupportTask: SpeziScheduler.Task<NAMSTaskContext> {
        let dateComponents: DateComponents
        if FeatureFlags.testSchedule {
            // Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
            dateComponents = DateComponents(
                hour: Calendar.current.component(.hour, from: .now),
                minute: Calendar.current.component(.minute, from: .now)
            )
        } else {
            // For the normal app usage, we schedule the task for every day at 8:00 AM
            dateComponents = DateComponents(hour: 8, minute: 0)
        }

        return Task(
            title: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_TITLE"),
            description: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_DESCRIPTION"),
            schedule: Schedule(
                start: Calendar.current.startOfDay(for: Date()),
                repetition: .matching(dateComponents),
                end: .numberOfEvents(365)
            ),
            notifications: true,
            context: NAMSTaskContext.questionnaire(Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire"))
        )
    }

    /// Creates a default instance of the ``NAMSScheduler`` by scheduling the tasks listed below.
    convenience init() {
        self.init(testSchedule: false)
    }

    /// Creates a default instance of the ``NAMSScheduler`` by scheduling the tasks listed below.
    convenience init(testSchedule: Bool) {
        self.init(tasks: [Self.socialSupportTask])
    }
}
