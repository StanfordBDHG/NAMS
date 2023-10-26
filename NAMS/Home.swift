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
        case eegRecording
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

#if MUSE
    @StateObject var eegModel = EEGViewModel(deviceManager: MuseDeviceManager())
#else
    @StateObject var eegModel = EEGViewModel(deviceManager: MockDeviceManager())
#endif

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView(presentingAccount: $presentingAccount, activePatientId: $activePatientId, eegModel: eegModel)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("Schedule", systemImage: "list.clipboard")
                }
            if eegModel.activeDevice?.state == .connected {
                NavigationStack {
                    EEGRecording(eegModel: eegModel)
                }
                .tag(Tabs.eegRecording)
                .tabItem {
                    Label("Recording", systemImage: "waveform.path")
                }
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
                    let patientId = "default-patient"
                    activePatientId = patientId
                    patientList.loadActivePatientWithTestAccount(for: patientId, viewState: $viewState, account: account)
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
            .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
                AccountSheet()
            }
            .verifyRequiredAccountDetails(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding)
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
#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))

    return HomeView()
        .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
        .environmentObject(NAMSScheduler(testSchedule: true))
        .environmentObject(MockWebService())
}
#endif
