//
//  TileView.swift
//  NAMS
//
//  Created by Andreas Bauer on 26.10.23.
//

import SwiftUI

struct EEGTile: View {
    var completed: Bool {
        false
    }

    var deviceConnected: Bool {
        false
    }

    var body: some View {
        // TODO: small view, if the thing was completed!

        // TODO: we might want to consider a instructions view for that one!
        VStack(alignment: .center) {
            if completed {

            } else {
                Image(systemName: "brain.fill")
                    .foregroundColor(.pink)
                    .font(.system(size: 50))
                Text("EEG Recording")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("\(String("5")) min")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            Divider()

            // TODO: hint to connect a device if there is none

            Text("Start a EEG Recording for the current patient ...", comment: "EEG Tile description")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.top)

            if !deviceConnected {
                let label = LocalizedStringResource("No EEG Headband connected ...", comment: "EEG Tile no headband warning")

                (Text("\(Image(systemName: "exclamationmark.triangle.fill")) ")
                    + Text(label))
                    .foregroundColor(.secondary)
                    .symbolRenderingMode(.multicolor)
                    .font(.footnote)
                    .padding(.top, 4)
                    .padding([.leading, .trailing])
                    .accessibilityLabel(Text(label))
            }

            // TODO: disable button if no device is present
            Button(action: {}) {
                Text("Start Recording")
                    .frame(maxWidth: .infinity, minHeight: 30)
            }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
                .tint(.pink)
        }
            .frame(maxWidth: .infinity)
            .containerShape(Rectangle())
            .disabled(!deviceConnected)
    }
}


#if DEBUG
#Preview {
    List {
        EEGTile()
    }
}
#endif
