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

    @IBOutlet weak var mirrorView: MirrorView!
    @IBOutlet weak var touchDisplay: TouchDisplay!
    @IBOutlet weak var mirrorAspectRatioConstraint: NSLayoutConstraint!

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
        view.isMultipleTouchEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true

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

            guard let data = Data(base64Encoded: encodedImage), var image = CIImage(data: data) else {
                return
            }

            // rotate the image to force landscape on phones
            // ugly hack but its functional until full rotation support can be added throughout the interface
            if UIDevice.current.userInterfaceIdiom == .phone {
                image = image.oriented(.right)
            }

            self.mirrorView.image = image

            // update the mirrors aspect ratio constraint
            let aspectRatio = image.extent.width / image.extent.height
            if self.mirrorAspectRatioConstraint.multiplier != aspectRatio {
                let newConstraint = NSLayoutConstraint(item: self.mirrorAspectRatioConstraint.firstItem!,
                                                       attribute: self.mirrorAspectRatioConstraint.firstAttribute,
                                                       relatedBy: self.mirrorAspectRatioConstraint.relation,
                                                       toItem: self.mirrorAspectRatioConstraint.secondItem,
                                                       attribute: self.mirrorAspectRatioConstraint.secondAttribute,
                                                       multiplier: aspectRatio,
                                                       constant: self.mirrorAspectRatioConstraint.constant)

                self.mirrorView.removeConstraint(self.mirrorAspectRatioConstraint)
                self.mirrorView.addConstraint(newConstraint)
                self.mirrorView.layoutIfNeeded()
                self.mirrorAspectRatioConstraint = newConstraint
            }

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
        guard let screenshot = mirrorView.image else {
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
        // defer touches to the touch display
        // since touchesMoved defers here, ensure that this is a new touch as to
        // not spam indicators on the display when dragging
        if !touches.contains(where: { ongoingTouchIds[$0] != nil }) {
            touchDisplay.touchesBegan(touches, with: event)
        }

        for touch in touches {
            // register an id for the touch, if it has not been done already
            if ongoingTouchIds[touch] == nil {
                // there is a bug in spice where id 0 will direct to the wrong display
                // counter this by starting ids at 1
                ongoingTouchIds[touch] = ongoingTouchIds.count + 1
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
        var imageWidth = mirrorView.image?.extent.width ?? 0
        var imageHeight = mirrorView.image?.extent.height ?? 0
        let widthDifference = mirrorView.bounds.width / imageWidth
        let heightDifference = mirrorView.bounds.height / imageHeight
        if widthDifference > heightDifference {
            imageSize = CGSize(width: mirrorView.bounds.height / imageHeight * imageWidth, height: mirrorView.bounds.height)
        }
        else if heightDifference > widthDifference {
            imageSize = CGSize(width: mirrorView.bounds.width, height: mirrorView.bounds.width / imageWidth * imageHeight)
        }
        else {
            imageSize = mirrorView.bounds.size
        }

        let imageBounds = CGRect(
            x: (mirrorView.bounds.width - imageSize.width) / 2,
            y: (mirrorView.bounds.height - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )

        // translate the touch point to mirror image coordinates
        var imagePoint = touch.location(in: self.mirrorView)
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
