//
//  KeypadView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-13.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A view for controlling the keypad.
struct KeypadView: View {
    var body: some View {
        StoryboardRepresentable(storyboard: "Keypad")
            .edgesIgnoringSafeArea(.all)
    }
}
