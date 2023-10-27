//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
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

    @EnvironmentObject private var account: Account

    @State private var patientList = PatientListModel()

    @State private var viewState: ViewState = .idle
    @State private var presentingAccount = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView(presentingAccount: $presentingAccount, activePatientId: $activePatientId)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("Schedule", systemImage: "list.clipboard")
                }
            Contacts(presentingAccount: $presentingAccount)
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
            if FeatureFlags.disableFirebase {
                MockUpload(presentingAccount: $presentingAccount)
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
                    Task {
                        let patientId = "default-patient"
                        await patientList.setupTestEnvironment(withPatient: patientId, viewState: $viewState, account: account)

                        activePatientId = patientId // this will trigger the onChange below, loading the patient info
                        handlePatientIdChange()
                    }
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
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding && !FeatureFlags.injectDefaultPatient) {
                AccountSheet()
            }
            .verifyRequiredAccountDetails(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding)
    }


    func handlePatientIdChange() {
        guard !FeatureFlags.disableFirebase else {
            return
        }

        if let activePatientId {
            patientList.loadActivePatient(for: activePatientId, viewState: $viewState, activePatientId: $activePatientId)
        } else {
            patientList.removeActivePatientListener()
        }
    }
}


#if DEBUG
#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return HomeView()
        .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
        .environmentObject(MockWebService())
}
#endif
