//
//  CardFlowerBackground.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-04.
//

import SwiftUI

/// A stylized background for use within a `CardView` named "flower".
struct CardFlowerBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .position(x: geometry.size.width, y: geometry.size.height / 2)

            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .position(x: geometry.size.width, y: geometry.size.height)

            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .position(x: geometry.size.width - geometry.size.height / 2, y: geometry.size.height)
        }
        .opacity(0.1)
        .blendMode(.saturation)
    }
}

// MARK: - Previews

struct CardFlowerBackground_Previews: PreviewProvider {
    static var previews: some View {
        CardFlowerBackground()
            .frame(height: 300)
            .mask(Rectangle())
            .background(.blue)
    }
}
