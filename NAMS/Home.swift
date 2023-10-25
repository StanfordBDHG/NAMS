//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziMockWebService
import SpeziViews
import SwiftUI


@MainActor
struct HomeView: View {
    enum Tabs: String {
        case schedule
        case contact
        case mockUpload
    }
    
    @AppStorage(StorageKeys.homeTabSelection)
    private var selectedTab = Tabs.schedule
    @AppStorage(StorageKeys.selectedPatient)
    private var activePatientId: String?

    @State private var patientList = PatientListModel()

    @State private var viewState: ViewState = .idle

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView(activePatientId: $activePatientId)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("Schedule", image: "list.clipboard")
                }
            Contacts()
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
            if FeatureFlags.disableFirebase {
                MockUpload()
                    .tag(Tabs.mockUpload)
                    .tabItem {
                        Label("MOCK_UPLOAD_TAB_TITLE", systemImage: "server.rack")
                    }
            }
        }
            .environment(patientList)
            .viewStateAlert(state: $viewState)
            .onAppear {
                if FeatureFlags.injectDefaultPatient {
                    let patientId = "default-patient"
                    activePatientId = patientId
                    patientList.loadActivePatientWithTestAccount(for: patientId, viewState: $viewState)
                    return
                }

                handlePatientIdChange()
            }
            .onDisappear {
                patientList.removeActivePatientListener()
            }
            .onChange(of: activePatientId, handlePatientIdChange)
            .onChange(of: viewState) { oldValue, newValue in
                if case .error = oldValue,
                   case .idle = newValue {
                    activePatientId = nil // reset the current patient on an error
                }
            }
    }


    func handlePatientIdChange() {
        guard !FeatureFlags.disableFirebase else {
            return
        }

        if let activePatientId {
            patientList.loadActivePatient(for: activePatientId, viewState: $viewState)
        } else {
            patientList.removeActivePatientListener()
        }
    }
}


#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NAMSScheduler(testSchedule: true))
            .environmentObject(MockWebService())
    }
}
#endif
