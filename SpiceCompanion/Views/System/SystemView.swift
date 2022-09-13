//
//  SystemView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-13.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A view for information about and control of the system.
struct SystemView: View {
    var body: some View {
        StoryboardRepresentable(storyboard: "System")
            .edgesIgnoringSafeArea(.all)
    }
}
