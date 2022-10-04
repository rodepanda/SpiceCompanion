//
//  CardView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-04.
//

import SwiftUI

/// A view for displaying a card in prominent, stylized appearance.
struct CardView: View {

    /// The configuration of this card's background.
    private let backgroundConfiguration: CardBackground.Configuration

    /// The card that this view is displaying.
    let card: Card

    var body: some View {
        CardBackground(configuration: backgroundConfiguration)
            .aspectRatio(4 / 2.5, contentMode: .fit)
            .shadow(color: backgroundConfiguration.color.opacity(0.5), radius: 10)
            .overlay {
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        Text(card.name)
                        Spacer()
                        Image(systemName: "wave.3.forward.circle.fill")
                    }
                    .font(.system(.title, design: .rounded).bold())

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text("•••• " + card.number.suffix(4))
                            .font(.system(.subheadline, design: .monospaced).bold())

                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
            .mask(RoundedRectangle(cornerRadius: 10))
    }

    init(card: Card) {
        self.card = card
        self.backgroundConfiguration = CardBackground.Configuration(card: card)
    }
}

// MARK: - Previews

struct CardView_Previews: PreviewProvider {

    /// All the cards to display previews for.
    private static let cards = [
        Card(name: "preview", number: "E004ADEFCADDE76F"),
        Card(name: "Preview", number: "E0048C7E2269B5A3"),
        Card(name: "PREVIEW", number: "E0044D55C4F0EF92"),
        Card(name: "spice", number: "E0042AE8FB812713"),
        Card(name: "Spice", number: "E0046F8244618E1A"),
        Card(name: "SPICE", number: "E004427099CC9704"),
        Card(name: "name", number: "E004FC89BEBAF32C"),
        Card(name: "Name", number: "E004B94872E80649"),
        Card(name: "NAME", number: "E0044F3F6F8B2AED"),
        Card(name: "SOMETHING REALLY LONG TO SEE HOW MULTILINE WORKS OUT", number: "E004957801F6A4FC"),
    ]

    static var previews: some View {
        ForEach(cards) { card in
            CardView(card: card)
                .padding()
                .previewDisplayName(card.name)
        }
        .previewLayout(.sizeThatFits)
    }
}
