//
//  CardBackground.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-04.
//

import SwiftUI
import CryptoKit

/// The background of a `CardView`.
struct CardBackground: View {

    /// The configuration of this background.
    let configuration: Configuration

    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                colors: [
                    configuration.color,
                    configuration.color.adjust(hue: -0.1, saturation: 0.1),
                ],
                startPoint: .bottomTrailing,
                endPoint: .topLeading)
            )
            .overlay {
                Group {
                    switch configuration.style {
                    case .waves:
                        CardWavesBackground()
                    case .flower:
                        CardFlowerBackground()
                    case .stripes:
                        CardStripesBackground()
                    }
                }
                .mask(Rectangle())
            }
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    init(card: Card) {
        self.configuration = Configuration(card: card)
    }
}

// MARK: - Structures

extension CardBackground {
    /// The configuration of a card background's appearance.
    struct Configuration {

        /// The different colours that can be chosen when generating a configuration from a card.
        private let generatedColors = [
            Color.blue,
            Color.cyan,
            Color.gray,
            Color.green,
            Color.indigo,
            Color.mint,
            Color.orange,
            Color.pink,
            Color.purple,
            Color.teal,
            Color.yellow,
        ]

        /// The prominent color of the background.
        let color: Color

        /// The style of the background.
        let style: Style

        init(color: Color, style: CardBackground.Configuration.Style) {
            self.color = color
            self.style = style
        }

        init(card: Card) {
            let numberHash = SHA256.hash(data: card.number.data(using: .utf8)!)
            let hashValues = numberHash.map { Int($0) }

            func getHashInt(index: Int) -> Int {
                let intSize = MemoryLayout<Int>.size
                let absoluteOffset = index * intSize
                return hashValues[absoluteOffset..<absoluteOffset + intSize].reduce(0, +)
            }

            let colorIndex = getHashInt(index: 0) % generatedColors.count
            let styleIndex = getHashInt(index: 2) % Configuration.Style.allCases.count
            self.color = generatedColors[colorIndex]
            self.style = Configuration.Style.allCases[styleIndex]
        }
    }
}

// MARK: - Enumerations

extension CardBackground.Configuration {
    /// The different styles of background.
    enum Style: CaseIterable {

        /// Circular waves radiating across the background.
        case waves

        /// A flower-esque layer of circles in the corner.
        case flower

        /// A sequence of angled stripes across the background.
        case stripes
    }
}

// MARK: - Previews

struct CardBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardBackground(configuration: CardBackground.Configuration(color: .purple, style: .waves))
                .aspectRatio(3 / 2, contentMode: .fit)

            CardBackground(configuration: CardBackground.Configuration(color: .blue, style: .flower))
                .aspectRatio(3 / 2, contentMode: .fit)

            CardBackground(configuration: CardBackground.Configuration(color: .green, style: .stripes))
                .aspectRatio(3 / 2, contentMode: .fit)

            CardBackground(card: Card(name: "", number: "E004001122334455"))
                .aspectRatio(3 / 2, contentMode: .fit)
        }
    }
}
