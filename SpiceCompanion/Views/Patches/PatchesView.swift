//
//  PatchesView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-13.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A view for managing memory patches.
struct PatchesView: View {
    var body: some View {
        StoryboardRepresentable(storyboard: "Patches")
            .edgesIgnoringSafeArea(.all)
    }
}
