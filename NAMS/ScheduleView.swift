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


struct ScheduleView: View {
    @Environment(BiopotDevice.self)
    private var biopot: BiopotDevice?
    @Environment(PatientListModel.self)
    private var patientList

    @State private var presentingMuseList = false
    @State private var presentPatientSheet = false
    @Binding private var presentingAccount: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                if patientList.activePatientId == nil {
                    ContentUnavailableView {
                        Label("No Patient selected", systemImage: "person.fill")
                    } description: {
                        Text("Select a patient to continue.")
                    } actions: {
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
                    PatientListSheet()
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
                CurrentPatientLabel()
            })
        }
        ToolbarItem(placement: .primaryAction) {
            AccountButton(isPresented: $presentingAccount)
        }
    }


    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}


#if DEBUG
#Preview {
    ScheduleView(presentingAccount: .constant(true))
        .previewWith(standard: NAMSStandard()) {
            EEGRecordings()
            DeviceCoordinator()
            PatientListModel()
            Bluetooth {
                Discover(BiopotDevice.self, by: .advertisedService(BiopotService.self))
            }
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
