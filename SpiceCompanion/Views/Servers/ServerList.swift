//
//  ServerList.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-22.
//

import SwiftUI

/// An editable list of all the user's configured servers.
struct ServerList: View {

    @Environment(\.serversStore) private var store
    @Environment(\.scenePhase) private var scenePhase

    /// All the servers currently within this view.
    @State private var servers = [Server]()

    var body: some View {
        List(servers) { server in
            Text(server.name)
        }
        .navigationTitle("Servers")
        .navigationBarTitleDisplayMode(.large)
        .task {
            servers = (try? await store.load()) ?? []
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .inactive {
                Task {
                    try await store.save(contents: servers)
                }
            }
        }
    }
}

// MARK: - Previews

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerList()
        }
        .navigationViewStyle(.stack)
        .environment(\.serversStore, PreviewsServersStore())
    }

    /// A `ServersStore` which always loads preview data from memory.
    private class PreviewsServersStore: ServersStore {

        override func load() async throws -> [Server] {
            return [
                Server(name: "Server One", host: "hostname", port: 0),
                Server(name: "Server Two (Encrypted)", host: "127.0.0.1", port: 65535, password: "password"),
                Server(name: "Server Three (Encrypted)", host: "1.2.3.4", port: 8080, password: "PASSWORD"),
            ]
        }
    }
}
