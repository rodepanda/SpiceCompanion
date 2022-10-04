//
//  CardWavesBackground.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-04.
//

import SwiftUI

/// A stylized background for use within a `CardView` named "waves".
struct CardWavesBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .position()

            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .scaleEffect(2)
                .position()

            Circle()
                .fill(.black)
                .frame(width: geometry.size.height, height: geometry.size.height)
                .scaleEffect(3)
                .position()
        }
        .opacity(0.1)
        .blendMode(.saturation)
    }
}

// MARK: - Previews

struct CardWavesBackground_Previews: PreviewProvider {
    static var previews: some View {
        CardWavesBackground()
            .frame(height: 300)
            .mask(Rectangle())
            .background(.blue)
    }
}
