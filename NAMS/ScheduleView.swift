//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


struct ScheduleView2: View {
    @ObservedObject var eegModel: EEGViewModel

    @State var presentingMuseList = false
    @State var presentPatientSheet = false
    @Binding var presentingAccount: Bool

    @Binding var activePatientId: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if activePatientId == nil {
                    VStack {
                        NoInformationText {
                            Text("No Patient selected")
                        } caption: {
                            Text("Select a patient to continue.")
                        }

                        Button(action: {
                            presentPatientSheet = true
                        }) {
                            Text("Select Patient")
                        }
                            .padding()
                    }
                } else {
                    TilesView()
                }
            }
                .sheet(isPresented: $presentingMuseList) {
                    NearbyDevices(eegModel: eegModel)
                }
                .sheet(isPresented: $presentPatientSheet) {
                    PatientListSheet(activePatientId: $activePatientId)
                }
                .navigationTitle(Text("Schedule", comment: "Schedule Title"))
                .toolbar {
                    toolbar
                }
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        if activePatientId != nil {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentingMuseList = true
                }) {
                    Image(systemName: "brain.head.profile").symbolRenderingMode(.hierarchical)
                        .accessibilityLabel("NEARBY_DEVICES")
                }
            }
        }

        ToolbarItem(placement: .principal) {
            Button(action: {
                presentPatientSheet = true
            }, label: {
                CurrentPatientLabel(activePatient: $activePatientId)
            })
        }
        if AccountButton.shouldDisplay {
            ToolbarItem(placement: .primaryAction) {
                AccountButton(isPresented: $presentingAccount)
            }
        }
    }


    init(presentingAccount: Binding<Bool>, activePatientId: Binding<String?>, eegModel: EEGViewModel) {
        self._presentingAccount = presentingAccount
        self._activePatientId = activePatientId
        self.eegModel = eegModel
    }
}


#if DEBUG
#Preview {
    ScheduleView2(presentingAccount: .constant(true), activePatientId: .constant(nil), eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
        .environmentObject(Account(MockUserIdPasswordAccountService()))
        .environment(PatientListModel())
}

#Preview {
    ScheduleView2(presentingAccount: .constant(true), activePatientId: .constant("1"), eegModel: EEGViewModel(deviceManager: MockDeviceManager()))
        .environmentObject(Account(MockUserIdPasswordAccountService()))
        .environment(PatientListModel())
}
#endif
