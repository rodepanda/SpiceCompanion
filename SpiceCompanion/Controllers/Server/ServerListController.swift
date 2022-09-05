//
//  ServerListController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-04.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The view controller for displaying and editing a list of the user's servers, as well as opening a connection
/// to them.
class ServerListController: UITableViewController {

    /// The unique reuse identifier of the table view cell for displaying a server.
    private let serverCellIdentifier = "ServerCell"

    /// The unique reuse identifier of the view controller for editing a server.
    private let formControllerIdentifier = "ServerFormController"

    /// The unique reuse identifier of the view controller to present when a successful connection is made.
    private let mainControllerIdentifier = "MainTabBarController"

    /// The currently connected Spice client of this controller, if any.
    private var client: ConnectionController?

    /// All the servers displayed by this controller.
    private var servers: [Server] {
        get {
            SettingsStore.shared.settings.servers
        }
        set {
            SettingsStore.shared.settings.servers = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }

    /// Present a new form controller with the given context.
    /// - Parameter context: The context to use.
    private func presentForm(context: ServerFormController.Context) {
        guard let formController = storyboard?.instantiateViewController(identifier: formControllerIdentifier, creator: {
            let controller = ServerFormController(coder: $0, mode: context)
            controller?.delegate = self
            return controller
        }) else {
            fatalError("failed to load \(formControllerIdentifier) from storyboard")
        }

        let navigationController = UINavigationController(rootViewController: formController)
        present(navigationController, animated: true)
    }

    // MARK: - IBActions

    /// Present a new form controller for creating a new server.
    @IBAction private func presentNewServer() {
        presentForm(context: .new)
    }
}

// MARK: - UITableViewDataSource

extension ServerListController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: serverCellIdentifier, for: indexPath)
        let server = servers[indexPath.row]
        cell.textLabel?.text = server.name
        cell.detailTextLabel?.text = "\(server.host):\(server.port)"

        let image: UIImage?
        if server.password != nil {
            image = UIImage(systemName: "network.badge.shield.half.filled")
        }
        else {
            image = UIImage(systemName: "network")
        }

        cell.imageView?.image = image?.applyingSymbolConfiguration(.init(scale: .large))
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            try? SettingsStore.shared.save()
            break
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        servers.move(fromOffsets: [fromIndexPath.row], toOffset: to.row)
        tableView.moveRow(at: fromIndexPath, to: to)
        try? SettingsStore.shared.save()
    }
}

// MARK: - UITableViewDelegate

extension ServerListController {
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let server = servers[indexPath.row]
        presentForm(context: .edit(server: server))
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // begin connecting to the selected server
        let server = servers[indexPath.row]
        let client = ConnectionController(uiViewController: self, host: server.host, port: server.port, password: server.password)
        showConnectionDialogOverlay(title: "Connecting...")
        client.connect()
        self.client = client
    }
}

// MARK: - ServerFormDelegate

extension ServerListController: ServerFormDelegate {
    func serverForm(_ serverForm: ServerFormController, didCommitServer server: Server) {
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        else {
            servers.append(server)
            tableView.insertRows(at: [IndexPath(row: servers.count - 1, section: 0)], with: .automatic)
        }

        try? SettingsStore.shared.save()
    }
}

// MARK: - UIViewController+CustomDelegation

extension ServerListController {

    override func connectingSuccess() {
        // instantiate the new main controller and pass the client to it
        dismiss(animated: true) {
            guard let client = self.client, let storyboard = self.storyboard else {
                return
            }

            let mainController = storyboard.instantiateViewController(withIdentifier: self.mainControllerIdentifier) as! TabBarViewController
            client.setUIViewController(uiViewController: mainController)
            self.present(mainController, animated: true)
        }
    }

    override func connectingFailed() {
        // present an error message to the user
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                let alert = UIAlertController(title: "Error", message: "Could not connect to server", preferredStyle: .alert)
                alert.view.tintColor = .accentColor
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
