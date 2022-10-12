//
//  ServerForm.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-11.
//

import SwiftUI

/// A form for creating and modifying a server.
struct ServerForm: View {

    /// The intermediary value for translating the entered port into a server port.
    @State private var port: String

    /// The intermediary value for translating the entered password into a server password.
    @State private var password: String

    /// The server that this form is constructing.
    @State var server: Server

    /// Whether or not this form is currently presented.
    @Binding var isPresented: Bool

    /// The action to perform when this form's server is saved.
    let action: ((Server) -> Void)?

    /// Whether or not the currently entered values within this form can construct a valid server.
    private var isValid: Bool {
        return !server.name.isEmpty &&
               !server.host.isEmpty &&
               UInt16(port) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $server.name)
                    .textInputAutocapitalization(.words)

                Section("Host") {
                    TextField("Hostname", text: $server.host)
                    TextField("Port", text: $port)
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Section {
                    SecureField("Password", text: $password)
                } header: {
                    Text("Security")
                } footer: {
                    Text("Some features are unavailable without using a password.")
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Save") {
                        action?(server)
                    }
                    .disabled(!isValid)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: port) { newValue in
            if let newPort = UInt16(newValue) {
                server.port = newPort
            }
        }
        .onChange(of: password) { newValue in
            if newValue.isEmpty {
                server.password = nil
            }
            else {
                server.password = password
            }
        }
    }

    init(isPresented: Binding<Bool>, action: ((Server) -> Void)? = nil) {
        self.action = action
        self._isPresented = isPresented
        self._server = State(initialValue: Server(name: "", host: "", port: 0))
        self._port = State(initialValue: "")
        self._password = State(initialValue: "")
    }

    init(server: Server, isPresented: Binding<Bool>, action: ((Server) -> Void)? = nil) {
        self.action = action
        self._isPresented = isPresented
        self._server = State(initialValue: server)
        self._port = State(initialValue: String(server.port))
        self._password = State(initialValue: server.password ?? "")
    }
}

// MARK: - Previews

struct ServerForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServerForm(isPresented: .constant(true))
                .previewDisplayName("Add Server")

            ServerForm(server: Server(name: "Name", host: "host", port: 8080, password: "password"), isPresented: .constant(true))
                .previewDisplayName("Edit Server")
        }
    }
}
