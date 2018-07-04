    //
//  AppDelegate.swift
//  DemoApp
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import Applivery
import OCMSDK
import Orchextra
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    let appController = AppController.shared
    let session = Session.shared

    var backgroundSessionCompletionHandler: (() -> Void)?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
        let applivery = Applivery.shared
        applivery.start(apiKey: "7a177cbb986c1bf1b3fdf94240033385b1a7d91d",
                        appId: "59c9197a48563b7721347736", appStoreRelease: false)
        
		self.setupCache()
        
        if let credentials = self.session.loadORXCredentials() {
                self.appController.orchextraApiKey = credentials.apikey
                self.appController.orchextraApiSecret = credentials.apisecret
        }
        
        self.appController.window = self.window
        self.appController.homeDemo()
		
		return true
	}
	
	func setupCache() {
		let size = 100
		let cache = URLCache(
			memoryCapacity: size * 1024 * 1024,
			diskCapacity: size * 1024 * 1024,
			diskPath: "shared_cache"
		)
		
		URLSession.shared.configuration.urlCache = cache
		URLCache.shared = cache
	}
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }
    
    // MARK: - Handler notification
    
	func applicationWillResignActive(_ application: UIApplication) {

	}

	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	func applicationWillEnterForeground(_ application: UIApplication) {
        OCM.shared.applicationWillEnterForeground()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
    }

	func applicationWillTerminate(_ application: UIApplication) {
        
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        self.backgroundSessionCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        Orchextra.shared.handleLocalNotification(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    }
}
