//
//  ServerFormController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-04.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The view controller for creation and editing of a single server's properties.
class ServerFormController: UITableViewController {

    /// The context that this controller was instantiated in.
    private let context: Context

    /// The unique internal identifier of this controller's server.
    private let serverId: UUID

    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var hostnameTextField: UITextField!
    @IBOutlet private weak var portTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    /// The delegate for this controller to publish its events to.
    weak var delegate: ServerFormDelegate?

    init?(coder: NSCoder, mode: Context) {
        self.context = mode
        switch mode {
        case .new:
            serverId = UUID()
        case .edit(let server):
            serverId = server.id
        }

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch context {
        case .new:
            navigationItem.title = "Add Server"
            saveButton.isEnabled = false
        case .edit(let server):
            navigationItem.title = "Edit Server"
            saveButton.isEnabled = true
            nameTextField.text = server.name
            hostnameTextField.text = server.host
            portTextField.text = String(server.port)
            passwordTextField.text = server.password
        }
    }

    // MARK: - IBActions

    /// Validate all the currently entered properties of this controller and enable or disable the save button
    /// accordingly.
    @IBAction private func validateProperties() {
        saveButton.isEnabled =
            !(nameTextField.text ?? "").isEmpty &&
            !(hostnameTextField.text ?? "").isEmpty &&
            UInt16(portTextField.text ?? "") != nil
    }

    /// Dismiss this controller.
    @IBAction private func dismiss() {
        dismiss(animated: true)
    }

    /// Construct a new server from the properties entered into this controller and commit it to the delegate.
    ///
    /// It is assumed that the entered properties of this controller are validated before this method is called.
    @IBAction private func commit() {
        let server = Server(
            id: serverId,
            name: nameTextField.text!,
            host: hostnameTextField.text!,
            port: UInt16(portTextField.text!)!,
            password: passwordTextField.text!.isEmpty ? nil : passwordTextField.text!
        )

        delegate?.serverForm(self, didCommitServer: server)
        dismiss()
    }
}

// MARK: - Enumerations

extension ServerFormController {
    /// The different contexts that a `ServerFormController` can be instantiated in.
    enum Context {
        /// The controller is creating a new server.
        case new

        /// The controller is editing an existing server.
        case edit(server: Server)
    }
}
