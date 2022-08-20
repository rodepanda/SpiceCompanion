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
class MirrorViewController: UIViewController, PacketHandler {

    private var mirrorController: MirrorConnectionController!

    /// The index of the screen that this controller is currently presenting.
    var activeScreen = 0

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var mirrorImageView: UIImageView!

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
        view.isMultipleTouchEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true

        let touchDisplay = TouchDisplay(frame: view.frame)
        touchDisplay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(touchDisplay)

        let parentController = ConnectionController.get()
        mirrorController = MirrorConnectionController(
            uiViewController: self,
            host: parentController.host,
            port: parentController.port,
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

            guard let data = Data(base64Encoded: encodedImage), var image = UIImage(data: data) else {
                return
            }

            // rotate the image to force landscape on phones
            // ugly hack but its functional until full rotation support can be added throughout the interface
            if let cgImage = image.cgImage, UIDevice.current.userInterfaceIdiom == .phone {
                image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
            }

            self.mirrorImageView.image = image

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
        guard let screenshot = mirrorImageView.image else {
            return
        }

        let activityController = UIActivityViewController.init(activityItems: [screenshot], applicationActivities: nil)
        let configuration = [UIActivity.ActivityType.message] as? UIActivityItemsConfigurationReading
        activityController.activityItemsConfiguration = configuration

        self.present(activityController, animated: true, completion: nil)
    }

    // MARK: - Touch

    /// The unique identifiers of all the currently ongoing touches within this controller's mirror, keyed by said touches.
    private var ongoingTouchIds = [UITouch : Int]()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // register an id for the touch, if it has not been done already
            if ongoingTouchIds[touch] == nil {
                ongoingTouchIds[touch] = ongoingTouchIds.count
            }

            let id = ongoingTouchIds[touch]!
            guard let point = getScreenLocation(of: touch) else {
                continue
            }

            let packet = TouchWritePacket(id: id, x: Int(point.x), y: Int(point.y))
            ConnectionController.get().sendPacket(packet: packet)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let id = ongoingTouchIds[touch] else {
                continue
            }

            let packet = TouchResetPacket(id: id)
            ConnectionController.get().sendPacket(packet: packet)
            ongoingTouchIds.removeValue(forKey: touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    /// Get the touch point of the given touch within this controller's mirror.
    /// - Parameter touch: The touch to get the location of.
    /// - Returns: The top-left oriented, mirror-spaced point of the given touch, if any.
    func getScreenLocation(of touch: UITouch) -> CGPoint? {
        // calculate the displayed bounds of the mirrored image for touch translation
        var imageSize: CGSize
        var imageWidth = mirrorImageView.image?.size.width ?? 0
        var imageHeight = mirrorImageView.image?.size.height ?? 0
        let widthDifference = mirrorImageView.bounds.width / imageWidth
        let heightDifference = mirrorImageView.bounds.height / imageHeight
        if widthDifference > heightDifference {
            imageSize = CGSize(width: mirrorImageView.bounds.height / imageHeight * imageWidth, height: mirrorImageView.bounds.height)
        }
        else if heightDifference > widthDifference {
            imageSize = CGSize(width: mirrorImageView.bounds.width, height: mirrorImageView.bounds.width / imageWidth * imageHeight)
        }
        else {
            imageSize = mirrorImageView.bounds.size
        }

        let imageBounds = CGRect(
            x: (mirrorImageView.bounds.width - imageSize.width) / 2,
            y: (mirrorImageView.bounds.height - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )

        // translate the touch point to mirror image coordinates
        var imagePoint = touch.location(in: self.mirrorImageView)
        imagePoint.x -= imageBounds.origin.x
        imagePoint.y -= imageBounds.origin.y
        imagePoint.x *= imageWidth / imageBounds.width
        imagePoint.y *= imageHeight / imageBounds.height

        // translate from forced landscape coordinates to mirror coordinates
        if UIDevice.current.userInterfaceIdiom == .phone {
            let x = imagePoint.y
            let y = (imagePoint.x * -1) + imageWidth
            imagePoint =  CGPoint(x: x, y: y)

            let width = imageHeight
            let height = imageWidth
            imageWidth = width
            imageHeight = height
        }

        // limit touches to the bounds of the display, else the server will freak out
        guard (imagePoint.x >= 0 && imagePoint.x <= imageWidth) && (imagePoint.y >= 0 && imagePoint.y <= imageHeight) else {
            return nil
        }

        return imagePoint
    }
}
