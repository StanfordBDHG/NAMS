//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport)
import SpeziAccount
import SpeziBluetooth
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

    @Environment(Account.self)
    private var account
    @Environment(DeviceCoordinator.self)
    private var deviceCoordinator
    @Environment(Bluetooth.self)
    private var bluetooth
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?
    @Environment(PatientListModel.self)
    private var patientList

    @State var mockDeviceManager: MockDeviceManager?
    
#if MUSE
    @State var museDeviceManager = MuseDeviceManager()
#endif

    @State private var viewState: ViewState = .idle
    @State private var presentingAccount = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView(presentingAccount: $presentingAccount)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("Schedule", systemImage: "list.clipboard")
                }
            Contacts(presentingAccount: $presentingAccount)
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
        }
            .viewStateAlert(state: $viewState)
            .environment(mockDeviceManager)
#if MUSE
            .environment(museDeviceManager)
#endif
            .autoConnect(enabled: deviceCoordinator.shouldAutoConnectBiopotBackground, with: bluetooth)
            .onAppear {
                guard !ProcessInfo.processInfo.isPreviewSimulator else {
                    return
                }

                if FeatureFlags.injectDefaultPatient {
                    Task {
                        let patientId = "default-patient"
                        await patientList.setupTestEnvironment(withPatient: patientId, viewState: $viewState, account: account)

                        patientList.activePatientId = patientId // this will trigger the onChange below, loading the patient info
                        handlePatientIdChange()
                    }
                    return
                }

                handlePatientIdChange()
            }
            .onDisappear {
                patientList.removeActivePatientListener()
            }
            .onChange(of: deviceCoordinator.enableMockDevice, initial: true) {
                if deviceCoordinator.enableMockDevice && mockDeviceManager == nil {
                    mockDeviceManager = MockDeviceManager()
                } else if !deviceCoordinator.enableMockDevice && mockDeviceManager != nil {
                    mockDeviceManager = nil
                }
            }
            .onChange(of: patientList.activePatientId, handlePatientIdChange)
            .onChange(of: biopot != nil) {
                guard let biopot else {
                    return
                }

                // a new device is connected now
                deviceCoordinator.notifyConnectingDevice(.biopot(biopot))
            }
#if MUSE
            .onChange(of: museDeviceManager.connectedMuse) { _, muse in
                guard let muse else {
                    return
                }

                deviceCoordinator.notifyConnectingDevice(.muse(muse))
            }
#endif
            .onChange(of: viewState) { oldValue, newValue in
                if case .error = oldValue,
                   case .idle = newValue {
                    patientList.activePatientId = nil // reset the current patient on an error
                }
            }
            .onChange(of: account.signedIn) {
                if !account.signedIn {
                    patientList.activePatientId = nil // reset the current patient, will clear model state!
                }
            }
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(!FeatureFlags.skipOnboarding && !FeatureFlags.injectDefaultPatient) {
                AccountSheet()
            }
    }


    func handlePatientIdChange() {
        if let activePatientId = patientList.activePatientId {
            patientList.loadActivePatient(for: activePatientId, viewState: $viewState)
        } else {
            patientList.removeActivePatientListener()
        }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.accountId = UUID().uuidString
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return HomeView()
        .previewWith(standard: NAMSStandard()) {
            DeviceCoordinator()
            EEGRecordings()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
            PatientListModel()
        }
}
#endif
