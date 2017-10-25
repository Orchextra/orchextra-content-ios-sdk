//
//  AppController.swift
//  OCMDemo
//
//  Created by Judith Medina on 25/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class AppController: NSObject, SettingOutput {
    
    static let shared = AppController()

    let application = Application()
    var window: UIWindow?
    
    
    // Attributes Orchextra
    let orchextraHost = "https://sdk.orchextra.io"
    var orchextraApiKey = "9d9f74d0a9b293a2ea1a7263f47e01baed2cb0f3"
    var orchextraApiSecret = "6a4d8072f2a519c67b0124656ce6cb857a55276a"
//    var orchextraApiKey = "ef08c4dccb7649b9956296a863db002a68240be2"
//    var orchextraApiSecret = "6bc18c500546f253699f61c11a62827679178400"

    func homeDemo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? ViewController else {
            return
        }
        let navigationController = UINavigationController(rootViewController: settingsVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navigationController
    }
    
    func settings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC else {
            return
        }
        settingsVC.settingOutput = self
//        self.window?.rootViewController = settingsVC

        self.application.presentModal(settingsVC)
    }
    
    func orxCredentialesHasChanged(apikey: String, apiSecret: String) {
        self.orchextraApiKey = apikey
        self.orchextraApiSecret = apiSecret
        self.homeDemo()
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
