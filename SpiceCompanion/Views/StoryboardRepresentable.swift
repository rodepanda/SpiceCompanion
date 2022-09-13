//
//  StoryboardRepresentable.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-12.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A `UIViewControllerRepresentable` that represents the root view controller of a storyboard.
struct StoryboardRepresentable: UIViewControllerRepresentable {

    /// The storyboard containing this representable's view controller as its initial view controller.
    private let storyboard: UIStoryboard

    init(storyboard storyboardName: String) {
        self.storyboard = UIStoryboard(name: storyboardName, bundle: .main)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        return storyboard.instantiateInitialViewController()!
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
