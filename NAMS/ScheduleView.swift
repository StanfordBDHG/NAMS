//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziBluetooth
import SwiftUI


struct ScheduleView: View {
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?

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
                .navigationTitle(Text("Schedule", comment: "Schedule Title"))
                .sheet(isPresented: $presentingMuseList) {
                    NearbyDevicesView()
                }
                .sheet(isPresented: $presentPatientSheet) {
                    PatientListSheet(activePatientId: $activePatientId)
                }
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

        ToolbarItem(placement: .principal) {
            Button(action: {
                presentPatientSheet = true
            }, label: {
                CurrentPatientLabel(activePatient: $activePatientId)
            })
        }
        ToolbarItem(placement: .primaryAction) {
            AccountButton(isPresented: $presentingAccount)
        }
    }


    init(presentingAccount: Binding<Bool>, activePatientId: Binding<String?>) {
        self._presentingAccount = presentingAccount
        self._activePatientId = activePatientId
    }
}


#if DEBUG
#Preview {
    ScheduleView(presentingAccount: .constant(true), activePatientId: .constant(nil))
        .environment(PatientListModel())
        .environment(EEGRecordings())
        .previewWith {
            DeviceCoordinator()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}

#Preview {
    ScheduleView(presentingAccount: .constant(true), activePatientId: .constant("1"))
        .environment(PatientListModel())
        .environment(EEGRecordings())
        .previewWith {
            DeviceCoordinator()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(.biopotService))
            }
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}
#endif
