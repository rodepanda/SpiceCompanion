//
//  MirrorView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-21.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// A view that renders frames from a source display, allowing touch interactions to simulate a touchscreen
/// monitor.
class MirrorView: UIView {

    /// The view used by this view to render frames from the mirrored screen.
    private var renderView: MirrorRenderView

    /// The view used by this view to display touches performed on the mirrored screen.
    private var touchDisplayView: MirrorTouchDisplayView

    /// The extents of the last value that `frameImage` was set to.
    private var lastFrameExtent: CGRect?

    /// The current constraint on this view used to maintain the aspect ratio of the mirrored screen.
    private var aspectRatioConstraint: NSLayoutConstraint!

    /// The unique identifiers of all the currently ongoing touches within this view, keyed by said touches.
    private var ongoingTouchIds = [UITouch : Int]()

    /// The delegate for this view to post its events to.
    weak var delegate: MirrorViewDelegate?

    /// The current frame for this view to display.
    var frameImage: CIImage? {
        get {
            return renderView.image
        }
        set {
            // rotate the image to force landscape orientation
            // ugly hack but its functional until full rotation support can be
            // added throughout the interface
            var image = newValue
            if shouldUseForcedLandscape(for: image?.extent ?? .zero) {
                image = image?.oriented(.right)
            }

            renderView.image = image
            updateAspectRatio()
            lastFrameExtent = image?.extent
        }
    }

    required init?(coder: NSCoder) {
        renderView = MirrorRenderView()
        touchDisplayView = MirrorTouchDisplayView()
        super.init(coder: coder)
        clipsToBounds = true
        isMultipleTouchEnabled = true

        renderView.frame = CGRect(origin: .zero, size: frame.size)
        renderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(renderView)

        touchDisplayView.frame = CGRect(origin: .zero, size: frame.size)
        touchDisplayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(touchDisplayView)

        // create the initial aspect ratio constraint
        updateAspectRatio()
    }

    /// Update the aspect ratio constraint of this view based on the current `frameImage`.
    private func updateAspectRatio() {
        // this can be performed before an initial frame is set, so use a
        // default aspect ratio to satisfy layout
        let frameExtent: CGRect
        if let frameImage = frameImage {
            frameExtent = frameImage.extent
        }
        else {
            frameExtent = CGRect(x: 0, y: 0, width: 16, height: 9)
        }

        // only update the constraint if it needs to be changed
        if aspectRatioConstraint == nil || frameImage?.extent != lastFrameExtent {
            let aspectRatio = frameExtent.width / frameExtent.height
            let newConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .height,
                                                   multiplier: aspectRatio,
                                                   constant: 0)

            if aspectRatioConstraint != nil {
                removeConstraint(aspectRatioConstraint)
            }

            addConstraint(newConstraint)
            layoutIfNeeded()
            aspectRatioConstraint = newConstraint
        }
    }

    /// Get whether or not a frame should be displayed in forced lanscape orientation.
    /// - Parameter extent: The extent of the frame to check.
    /// - Returns: Whether or not the frame should be displayed in forced lanscape orientation, based
    /// on the given extent of said frame.
    private func shouldUseForcedLandscape(for extent: CGRect) -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && extent.width > extent.height
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mirrorTouches = getTouches(from: touches, allowNewTouches: true)
        delegate?.mirrorView(self, touchesBegan: mirrorTouches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mirrorTouches = getTouches(from: touches)
        delegate?.mirrorView(self, touchesMoved: mirrorTouches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mirrorTouches = getTouches(from: touches, remove: true)
        delegate?.mirrorView(self, touchesEnded: mirrorTouches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    /// Get the mirror touches of the given screen-space touches within this view.
    /// - Parameter touches: The screen-space touches to get the mirror touches of.
    /// - Parameter allowNewTouches: Whether or not new touches should be allowed to be
    /// registered.
    /// - Parameter remove: Whether or not the given touches should be removed after being processed.
    /// - Returns: The mirror touches of the given screen-space touches.
    private func getTouches(from touches: Set<UITouch>, allowNewTouches: Bool = false, remove: Bool = false) -> [Touch] {
        return touches.compactMap { touch -> Touch? in
            if allowNewTouches {
                // register an id for the touch, if it has not been done already
                if ongoingTouchIds[touch] == nil {
                    // there is a bug in spice where id 0 will direct to the wrong display
                    // counter this by starting ids at 1
                    ongoingTouchIds[touch] = ongoingTouchIds.count + 1
                }
            }

            guard let id = ongoingTouchIds[touch] else {
                return nil
            }

            if remove {
                ongoingTouchIds.removeValue(forKey: touch)
            }

            guard let location = getScreenLocation(of: touch) else {
                return nil
            }

            return Touch(id: id, location: location)
        }
    }

    /// Get the location of the given touch within this view's mirrored screen.
    /// - Parameter touch: The touch to get the location of.
    /// - Returns: The top-left oriented, mirror-spaced location of the given touch, if any.
    private func getScreenLocation(of touch: UITouch) -> CGPoint? {
        guard let frameImage = frameImage else {
            return nil
        }

        // calculate the scale of the displayed mirror frame
        var frameWidth = frameImage.extent.width
        var frameHeight = frameImage.extent.height
        let frameScaleX = frameWidth / bounds.width
        let frameScaleY = frameHeight / bounds.height
        let screenLocation = touch.location(in: self)
        var frameLocation = CGPoint(x: screenLocation.x * frameScaleX,
                                    y: screenLocation.y * frameScaleY)

        // translate from forced landscape coordinates to mirror coordinates
        if shouldUseForcedLandscape(for: frameImage.extent) {
            let x = frameLocation.y
            let y = (frameLocation.x * -1) + frameWidth
            frameLocation =  CGPoint(x: x, y: y)

            let width = frameWidth
            frameWidth = frameHeight
            frameHeight = width
        }

        // ensure the frame location is within the mirrored displays bounds
        guard CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight).contains(frameLocation) else {
            return nil
        }

        return frameLocation
    }
}

// MARK: - Delegate

/// A protocol for an object which handles events from a `MirrorView`.
protocol MirrorViewDelegate: AnyObject {
    /// Tells the delegate that the given new touches have begun within the given mirror view.
    /// - Parameter mirrorView: The mirror view that the given touches originated from.
    /// - Parameter touches: The touches that began.
    func mirrorView(_ mirrorView: MirrorView, touchesBegan touches: [Touch])

    /// Tells the delegate that the given ongoing touches have moved within the given mirror view.
    /// - Parameter mirrorView: The mirror view that the given touches originated from.
    /// - Parameter touches: The touches that moved.
    func mirrorView(_ mirrorView: MirrorView, touchesMoved touches: [Touch])

    /// Tells the delegate that the given ongoing touches have ended within the given mirror view.
    /// - Parameter mirrorView: The mirror view that the given touches originated from.
    /// - Parameter touches: The touches that ended.
    func mirrorView(_ mirrorView: MirrorView, touchesEnded touches: [Touch])
}

// MARK: - Data Structures

/// A single touch performed on a mirror.
struct Touch {
    /// The unique identifier of this touch among the currently ongoing touches.
    let id: Int

    /// The screen-space, top-left oriented location of this touch within the mirror.
    let location: CGPoint
}
