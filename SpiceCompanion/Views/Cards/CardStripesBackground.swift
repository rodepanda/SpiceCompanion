//
//  CardStripesBackground.swift
//  SpiceCompanion
//
//  Created by Lauren Bridges on 2022-10-04.
//

import SwiftUI

/// A stylized background for use within a `CardView` named "stripes".
struct CardStripesBackground: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 20) {
                ForEach(0..<Int(ceil(geometry.size.width * 2 / 40)), id: \.self) { index in
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 20, height: geometry.size.height * 3)
                }
            }
            .offset(x: -geometry.size.width / 2, y: -geometry.size.height / 2)
            .rotationEffect(.degrees(45), anchor: .center)
        }
        .opacity(0.1)
        .blendMode(.saturation)
    }
}

struct CardStripesBackground_Previews: PreviewProvider {
    static var previews: some View {
        CardStripesBackground()
            .frame(height: 300)
            .mask(Rectangle())
            .background(.blue)
    }
}
