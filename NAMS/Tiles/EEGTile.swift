//
//  TileView.swift
//  NAMS
//
//  Created by Andreas Bauer on 26.10.23.
//

import SwiftUI

struct EEGTile: View {
    var body: some View {
        // TODO: small view, if the thing was completed!

        // TODO: we might want to consider a instructions view for that one!
        VStack(alignment: .center) {
            Image(systemName: "brain.fill")
                .foregroundColor(.pink)
                .font(.system(size: 50))
            Text("EEG Recording")
                .font(.title)
                .fontWeight(.semibold)
            Text("5 min")
                .foregroundColor(.secondary)
                .font(.subheadline)

            Divider()

            // TODO: hint to connect a device if there is none

            Text("Start a EEG Recording for the current patient ...")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.top)

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
    }
}


#if DEBUG
#Preview {
    List {
        EEGTile()
    }
}
#endif
