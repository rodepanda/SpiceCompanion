//
//  CardsView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-13.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A view for managing the user's digital NFC cards.
struct CardsView: View {
    var body: some View {
        StoryboardRepresentable(storyboard: "Cards")
            .edgesIgnoringSafeArea(.all)
    }
}
