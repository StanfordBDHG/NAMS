//
//  MuseList.swift
//  NAMS
//
//  Created by Andreas Bauer on 04.09.23.
//

import SwiftUI

struct MuseList: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var museModel: MuseViewModel

    private var troubleshootingUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        guard let docsUrl = URL(string: "https://choosemuse.my.site.com/s/article/Bluetooth-Troubleshooting") else { // TODO ?language=en_US
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    var body: some View {
        // TODO check if bluetooth is enabled?
        let pasd = museModel.logger.debug("Rendering muse list with \(museModel.nearbyMuses.count) device(s)")
        List { // swiftlint:disable:this closure_body_length
            Text("Make sure your headband is turned on and nearby.")
                .listRowBackground(Color.clear)
                .padding(.bottom, -8)
            Section {
                if museModel.nearbyMuses.isEmpty {
                    // TODO if we disconnect this doesn't appear?
                    ProgressView()
                    // TODO clear background?
                        .frame(maxWidth: .infinity)
                } else {
                    // TODO don't rely on index
                    ForEach(museModel.nearbyMuses.indices, id: \.self) { index in
                        let muse = museModel.nearbyMuses[index]

                        Button(action: {
                            museModel.tapMuse(atIndex: index)
                        }) {
                            HStack {
                                Group {
                                    Image(systemName: "headphones")
                                    Text(verbatim: "\(muse.getModel().description) - \(muse.getName().replacingOccurrences(of: "Muse-", with: ""))")
                                }
                                .foregroundColor(.primary)
                                Spacer()
                                if let activeMuse = museModel.activeMuse,
                                   activeMuse.muse.getName() == muse.getName() { // TODO other identity check!
                                    if activeMuse.state == .connecting { // TODO we can also query the state from the muse directly!
                                        ProgressView()
                                    } else if activeMuse.state == .connected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    } else if activeMuse.state == .needsUpdate {
                                        // TODO make this tapable! with information and instructions on how to update
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .symbolRenderingMode(.multicolor)
                                    }
                                    // TODO visualize disconnected?
                                    // otherwise the muse should disconnect soon
                                }
                            }
                        }
                    }
                }
            } footer: {
                HStack {
                    Text("Do you have problems connecting?")
                    Button(action: {
                        UIApplication.shared.open(troubleshootingUrl)
                    }) {
                        Text("Troubleshooting")
                            .font(.footnote)
                    }
                }
                    .padding(.top)
            }
        }
            .navigationTitle("Nearby Devices")
            .onAppear {
                museModel.startScanning()
            }
            .onDisappear {
                museModel.stopScanning()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        museModel.reloadScanning()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityLabel("Reload Device List")
                    }
                }
                // TODO retry arrow?
            }
    }

    init(museModel: MuseViewModel) {
        self.museModel = museModel
    }
}

struct MuseList_Previews: PreviewProvider {
    @StateObject static var model = MuseViewModel()
    static var previews: some View {
        NavigationStack {
            MuseList(museModel: model)
        }
    }
}
