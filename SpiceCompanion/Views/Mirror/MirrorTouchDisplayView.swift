//
//  MirrorTouchDisplayView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-20.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit
import SwiftUI

/// A view which displays touches performed on a `MirrorView` in a stylized manner.
class MirrorTouchDisplayView: UIView {

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        isMultipleTouchEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // add indicators for each touch
        // each indicator will automatically remove itself when it is finished
        for touch in touches {
            let location = touch.location(in: self)
            let indicator = IndicatorView()

            // center the indicator on the touch
            indicator.frame.origin = CGPoint(x: location.x - indicator.frame.width / 2,
                                             y: location.y - indicator.frame.height / 2)

            addSubview(indicator)
        }

        // passthrough touches
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - Indicator

extension MirrorTouchDisplayView {
    /// An indicator for a single touch within a `MirrorTouchDisplayView`.
    ///
    /// This view will automatically play its animation and remove itself from the view hierarchy upon being
    /// added to said view heirarchy.
    private class IndicatorView: UIView {
        /// The diameter of `ringView`.
        private let ringDiameter = CGFloat(100)

        /// The maximum normalized scale that `ringView` expands to.
        private let ringExpandedScale = CGFloat(1.25)

        /// The view for the ring element behind the crosshair.
        private let ringView: UIView

        /// The view for the crosshair element.
        private let crossHairView: UIView

        init() {
            // create the swiftui hosts for the ring and crosshair and add them
            // to the view hierarchy
            ringView = UIHostingController(rootView: Ring()).view
            ringView.frame = CGRect(x: 0, y: 0, width: ringDiameter, height: ringDiameter)
            ringView.backgroundColor = nil

            crossHairView = UIHostingController(rootView: CrossHair()).view
            crossHairView.sizeToFit()
            crossHairView.backgroundColor = nil

            super.init(frame: CGRect(x: 0, y: 0, width: ringDiameter * ringExpandedScale, height: ringDiameter * ringExpandedScale))
            isUserInteractionEnabled = false //dont steal touches
            ringView.center = center
            crossHairView.center = center

            addSubview(ringView)
            addSubview(crossHairView)
            resetAnimation()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToSuperview() {
            super.didMoveToSuperview()

            // automatically start the animation upon appearing
            performAnimation()
        }

        /// Reset all the animated state of this view.
        private func resetAnimation() {
            ringView.transform = .init(scaleX: 0.75, y: 0.75)
            ringView.alpha = 0
            crossHairView.alpha = 0
        }

        /// Perform this view's animation, and then remove it from its parent's view hierarchy.
        private func performAnimation() {
            resetAnimation()

            let options = KeyframeAnimationOptions(rawValue: AnimationOptions.curveEaseOut.rawValue)
            UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: options) {
                // ring
                // grow outwards, fading in and out
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.ringView.transform = .init(scaleX: self.ringExpandedScale, y: self.ringExpandedScale)
                }

                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.ringView.alpha = 1
                }

                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.ringView.alpha = 0
                }

                // crosshair
                // fade in and out
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.crossHairView.alpha = 1
                }

                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.crossHairView.alpha = 0
                }
            } completion: { _ in
                self.removeFromSuperview()
            }
        }

        // MARK: - Views

        /// A view for the ring element of an `IndicatorView`.
        private struct Ring: View {
            var body: some View {
                Circle()
                    .strokeBorder(.white, lineWidth: 4)
                    .blur(radius: 5)
                    .mask(Circle())
                    .shadow(color: .white, radius: 2)
            }
        }

        /// A view for the crosshair element of an `IndicatorView`.
        private struct CrossHair: View {
            /// The total size of each diagonal line within this crosshair.
            private let lineSize = CGSize(width: 60, height: 4)

            /// The spacing between the two portions of each diagonal line within this crosshair.
            private let lineSpacing = CGFloat(20)

            var body: some View {
                ZStack {
                    ZStack {
                        buildLine(.degrees(45))
                        buildLine(.degrees(-45))
                    }
                    .blur(radius: 5, opaque: false)

                    ZStack {
                        buildLine(.degrees(45))
                        buildLine(.degrees(-45))
                    }
                }
                .frame(width: lineSize.width, height: lineSize.width)
            }

            /// Build and return a new diagonal line for this crosshair.
            /// - Parameter angle: The angle to rotate the new line to.
            /// - Returns: The new line.
            private func buildLine(_ angle: Angle) -> some View {
                HStack(spacing: lineSpacing) {
                    Rectangle().fill(.white)
                    Rectangle().fill(.white)
                }
                .frame(width: lineSize.width, height: lineSize.height)
                .rotationEffect(angle)
            }
        }
    }
}
