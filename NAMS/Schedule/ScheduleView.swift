//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI


struct ScheduleView: View {
    @EnvironmentObject var scheduler: NAMSScheduler
    @State var eventContextsByDate: [Date: [EventContext]] = [:]
    @State var presentedContext: EventContext?
    @State var presentingMuseList = false
    @State var presentingEEGMeasurements = false

    #if MUSE
    @StateObject var eegModel = EEGViewModel(deviceManager: MuseDeviceManager())
    #else
    @StateObject var eegModel = EEGViewModel(deviceManager: MockDeviceManager())
    #endif

    
    var startOfDays: [Date] {
        Array(eventContextsByDate.keys)
    }
    
    
    var body: some View {
        NavigationStack {
            List(startOfDays, id: \.timeIntervalSinceNow) { startOfDay in
                Section(format(startOfDay: startOfDay)) {
                    ForEach(eventContextsByDate[startOfDay] ?? [], id: \.event) { eventContext in
                        EventContextView(eventContext: eventContext)
                            .onTapGesture {
                                if !eventContext.event.complete {
                                    presentedContext = eventContext
                                }
                            }
                    }
                }
            }
                .onChange(of: scheduler) { _ in
                    calculateEventContextsByDate()
                }
                .task {
                    calculateEventContextsByDate()
                }
                .sheet(item: $presentedContext) { presentedContext in
                    destination(withContext: presentedContext)
                }
                .sheet(isPresented: $presentingMuseList) {
                    NearbyDevices(eegModel: eegModel)
                }
                .sheet(isPresented: $presentingEEGMeasurements) {
                    NavigationStack {
                        EEGRecording(eegModel: eegModel)
                    }
                }
                .navigationTitle("SCHEDULE_LIST_TITLE")
                .toolbar {
                    toolbar
                }
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                presentingMuseList = true
            }) {
                Image(systemName: "brain.head.profile").symbolRenderingMode(.hierarchical)
                    .accessibilityLabel("NEARBY_DEVICES")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: { presentingEEGMeasurements = true }) {
                Image(systemName: "waveform.path")
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityLabel("EEG_RECORDING")
            }
        }
    }
    
    
    private func destination(withContext eventContext: EventContext) -> some View {
        @ViewBuilder var destination: some View {
            switch eventContext.task.context {
            case let .questionnaire(questionnaire):
                QuestionnaireView(questionnaire: questionnaire) { _ in
                    _Concurrency.Task {
                        await eventContext.event.complete(true)
                    }
                }
            case let .test(string):
                ModalView(text: string, buttonText: String(localized: "TASK_TEST_CLOSE_TITLE")) {
                    _Concurrency.Task {
                        await eventContext.event.complete(true)
                    }
                }
            }
        }

        return destination
    }
    
    
    private func format(startOfDay: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: startOfDay)
    }
    
    private func calculateEventContextsByDate() {
        let eventContexts = scheduler.tasks.flatMap { task in
            task
                .events(
                    from: Calendar.current.startOfDay(for: .now),
                    to: .numberOfEventsOrEndDate(100, .now)
                )
                .map { event in
                    EventContext(event: event, task: task)
                }
        }
            .sorted()
        
        let newEventContextsByDate = Dictionary(grouping: eventContexts) { eventContext in
            Calendar.current.startOfDay(for: eventContext.event.scheduledAt)
        }
        
        if newEventContextsByDate != eventContextsByDate {
            eventContextsByDate = newEventContextsByDate
        }
    }
}


#if DEBUG
struct SchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(NAMSScheduler(testSchedule: true))
    }
}
#endif
