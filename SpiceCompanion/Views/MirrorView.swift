//
//  MirrorView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-21.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit
import Metal
import MetalKit

/// A view for displaying a rapid sequence of images from a source display in `MirrorViewController`.
///
/// Note that this view stretches the images it displays to its full bounds, so the parent is responsible for
/// managing proper sizing of it.
class MirrorView: MTKView {

    /// The Metal command queue that this view is using for rendering.
    private let commandQueue: MTLCommandQueue

    /// The CoreImage context that this view is using for rendering images.
    private let context: CIContext

    /// The colour space for this view to render its image in.
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    /// The image for this view to display.
    var image: CIImage? {
        didSet {
            drawImage()
        }
    }

    required init(coder: NSCoder) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MirrorView: unable to create system metal device")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("MirrorView: unable to create command queue")
        }

        self.commandQueue = commandQueue
        context = CIContext(mtlDevice: device)

        super.init(coder: coder)
        self.device = device
        framebufferOnly = false
        enableSetNeedsDisplay = true
    }

    /// Draw this view's image to the current frame.
    private func drawImage() {
        guard let image = image,
              let drawable = currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        // scale and render the image to the full bounds of the drawable
        // cicontext.render likes to render the image upside down, so scale the
        // image in reverse and offset it accordingly when rendering
        let scaleX = drawableSize.width / image.extent.width
        let scaleY = drawableSize.height / image.extent.height
        let scaledImage = image.transformed(by: .init(scaleX: scaleX, y: -scaleY))
        let bounds = CGRect(x: 0, y: -drawableSize.height, width: drawableSize.width, height: drawableSize.height)
        context.render(scaledImage, to: drawable.texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: colorSpace)

        commandBuffer.present(drawable)
        commandBuffer.commit()
        setNeedsDisplay()
    }
}
