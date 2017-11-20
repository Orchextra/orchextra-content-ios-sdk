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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
        let applivery = Applivery.shared
        applivery.start(apiKey: "7a177cbb986c1bf1b3fdf94240033385b1a7d91d",
                        appId: "59c9197a48563b7721347736", appStoreRelease: false)
        
		self.setupCache()
		
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
    
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        OCM.shared.applicationWillEnterForeground()
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        self.backgroundSessionCompletionHandler = completionHandler
    }

    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        ORCPushManager.handlePush(notification)
    }

}
