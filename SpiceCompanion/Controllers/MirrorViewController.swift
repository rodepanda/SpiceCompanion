//
//  MirrorViewController.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit
import SwiftyJSON

/// The view controller for presenting a "mirror" projection of a screen present on the server.
class MirrorViewController: UIViewController, MirrorViewDelegate, PacketHandler {

    private var mirrorController: MirrorConnectionController!

    /// The index of the screen that this controller is currently presenting.
    var activeScreen = 0

    @IBOutlet weak var mirrorView: MirrorView!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        UIApplication.shared.isIdleTimerDisabled = true
        mirrorView.delegate = self

        let parentController = ConnectionController.get()
        mirrorController = MirrorConnectionController(
            uiViewController: self,
            host: parentController.server.host,
            port: parentController.server.port,
            password: parentController.getPassword()
        )

        mirrorController.setPacketHandler(packetHandler: self)
        mirrorController.connect()
    }

    // MARK: - Networking

    /// Request the next frame of the currently mirrored screen from the server.
    func requestFrame() {
        mirrorController.sendPacket(packet: MirrorPacket(screen: activeScreen))
    }

    func handlePacket(data: Array<JSON>) {
        DispatchQueue.main.async {
            guard data.count == 4, let encodedImage = data[3].string else {
                return
            }

            guard let data = Data(base64Encoded: encodedImage), let image = CIImage(data: data) else {
                return
            }

            self.mirrorView.frameImage = image

            // the share button is disabled until frames begin displaying
            self.shareButton.isEnabled = true

            // request the next frame
            self.requestFrame()
        }
    }

    // MARK: - Navigation

    @IBAction func cancelButtonPressed(_ sender: Any) {
        mirrorController.resetPacketHandler()
        mirrorController.disconnect()

        UIApplication.shared.isIdleTimerDisabled = false
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        guard let screenshot = mirrorView.frameImage else {
            return
        }

        let activityController = UIActivityViewController.init(activityItems: [screenshot], applicationActivities: nil)
        let configuration = [UIActivity.ActivityType.message] as? UIActivityItemsConfigurationReading
        activityController.activityItemsConfiguration = configuration

        self.present(activityController, animated: true, completion: nil)
    }

    // MARK: - MirrorViewDelegate

    func mirrorView(_ mirrorView: MirrorView, touchesBegan touches: [Touch]) {
        for touch in touches {
            let packet = TouchWritePacket(id: touch.id, x: Int(touch.location.x), y: Int(touch.location.y))
            ConnectionController.get().sendPacket(packet: packet)
        }
    }

    func mirrorView(_ mirrorView: MirrorView, touchesMoved touches: [Touch]) {
        self.mirrorView(mirrorView, touchesBegan: touches)
    }

    func mirrorView(_ mirrorView: MirrorView, touchesEnded touches: [Touch]) {
        for touch in touches {
            let packet = TouchResetPacket(id: touch.id)
            ConnectionController.get().sendPacket(packet: packet)
        }
    }
}
