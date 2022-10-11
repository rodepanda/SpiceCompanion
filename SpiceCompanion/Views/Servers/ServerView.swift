//
//  ServerView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-11.
//

import SwiftUI

/// A view for displaying a server in a prominent, stylized appearance.
struct ServerView: View {

    /// The server for this view to display.
    let server: Server

    /// The action to perform when this view's edit button is pressed.
    let action: (() -> Void)?

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.accentColor)
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay {
                VStack(alignment: .leading) {
                    HStack {
                        if server.isEncrypted {
                            Image(systemName: "network.badge.shield.half.filled")
                        }
                        else {
                            Image(systemName: "network")
                        }

                        Spacer()

                        Button {
                            action?()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                    .imageScale(.large)

                    Spacer()

                    Text(server.name)
                        .font(.headline)
                }
                .padding()
                .foregroundColor(.white)
            }
    }

    init(server: Server, action: (() -> Void)? = nil) {
        self.server = server
        self.action = action
    }
}

// MARK: - Previews

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ServerView(server: Server(name: "Unencrypted", host: "host", port: 8080))
            ServerView(server: Server(name: "Encrypted", host: "host", port: 8080, password: "password"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
