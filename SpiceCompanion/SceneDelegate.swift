//
//  SceneDelegate.swift
//  Spice
//
//  Created by Gianni on 13/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        do {
            try SettingsStore.shared.load()
        }
        catch let error {
            print("failed to load settings with error \(error), reverting to defaults")
            SettingsStore.shared.settings = Settings()
        }

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        do {
            try SettingsStore.shared.save()
        }
        catch let error {
            print("failed to save settings with error \(error)")
        }
    }
}
