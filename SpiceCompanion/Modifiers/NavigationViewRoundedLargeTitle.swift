//
//  NavigationViewRoundedLargeTitle.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-11.
//

import SwiftUI

/// A view modifier for applying a rounded font to the large title of a navigation view.
struct NavigationViewRoundedLargeTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let descriptor = UIFont.preferredFont(forTextStyle: .largeTitle).fontDescriptor
                                       .withDesign(.rounded)!
                                       .withSymbolicTraits(.traitBold)!

                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(descriptor: descriptor, size: descriptor.pointSize),
                ]
            }
    }
}

extension View {
    /// Apply a rounded font to the large title of this navigation view.
    func navigationViewRoundedLargeTitle() -> some View {
        modifier(NavigationViewRoundedLargeTitle())
    }
}
