//
//  OCM.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
/**
The OCM class provides you with methods for starting the framework and retrieve the ViewControllers to use within your app.


### Usage

You should use the `shared` property to get a unique singleton instance, then set your `logLevel`


### Overview

Once the framework is started, you can retrive the ViewControllers to show the content list


- Since: 1.0
- Version: 1.0
- Author: Alejandro Jiménez Agudo
- Copyright: Gigigo S.L.
*/

public protocol StatusView {
    func instantiate() -> UIView
}

open class OCM: NSObject {
	
	public static let shared = OCM()
	
	/**
	Type of OCM's logs you want displayed in the debug console
	
	- **none**: No log will be shown. Recommended for production environments.
	- **error**: Only warnings and errors. Recommended for develop environments.
	- **info**: Errors and relevant information. Recommended for testing OCM integration.
	- **debug**: Request and Responses to OCM's server will be displayed. Not recommended to use, only for debugging OCM.
	*/
	public var logLevel: LogLevel {
		didSet {
			LogManager.shared.logLevel = self.logLevel
		}
	}
	
	public var delegate: OCMDelegate?
	public var analytics: OCMAnalytics?
	
	
	public var host: String {
		didSet {
			Config.Host = self.host
		}
	}
	
	public var countryCode: String {
		didSet {
			Config.CountryCode = self.countryCode
		}
	}
	
	public var appVersion: String {
		didSet {
			Config.AppVersion = self.appVersion
		}
	}
	
	public var palette: Palette? {
		didSet {
			Config.Palette = self.palette
		}
	}
	
	public var placeholder: UIImage? {
		didSet {
			Config.placeholder = self.placeholder
		}
	}
	
    public var loadingView: StatusView? {
        didSet {
            Config.loadingView = self.loadingView
        }
    }
    
	public var noContentImage: UIImage? {
		didSet {
			Config.noContentImage = self.noContentImage
		}
	}
	
	internal let wireframe = Wireframe(
		application: Application()
	)
	
	override init() {
		self.logLevel = .none
		LogManager.shared.appName = "OCM"
		self.host = ""
		self.countryCode = ""
		self.appVersion = ""
		self.placeholder = nil
        super.init()
        self.loadFonts()
	}
	
	/**
	Retrieve the section list
	
	Use it to build a dynamic menu in your app
	
	- returns: Dictionary of sections to be represented
	
	- Since: 1.0
	*/
	public func menus(completionHandler: @escaping ([Menu]) -> Void) {
		MenuCoordinator().menus(completion:
			completionHandler)
	}
	
	/**
	Run the action from an url
	
	**Discussion:** It will be executed only if was previously loaded.
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter uri: The url that represent the action to run
	
	- Since: 1.0
	*/
	public func openAction(from uri: String) -> UIViewController? {
		return nil//self.wireframe.contentList(from: uri)
	}
	
	/**
	Retrieve the content list view controller
	
	Use it to present this view to your users
	
	- returns: ViewController to be presented
	
	- Since: 1.0
	*/
	public func notificationReceived(_ notification: [AnyHashable : Any]) {
		PushInteractor().pushReceived(notification)
	}
    
    private func loadFonts() {
        UIFont.loadSDKFont(fromFile: "gotham-ultra.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-medium.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-light.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-book.ttf")
    }
}

public protocol OCMDelegate {
	func openCoupons()
	func openCoupon(with id: String)
	func customScheme(_ url: URLComponents)
	func sessionExpired()
}

public protocol OCMAnalytics {
	func trackEvent(_ eventName: String)
}
