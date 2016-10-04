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

Once the framework is started, you can retrive the ViewControllers to show the widget list


- Since: 1.0
- Version: 1.0
- Author: Alejandro Jiménez Agudo
- Copyright: Gigigo S.L.
*/
open class OCM {
	
	open static let shared = OCM()
	
	/**
	Type of OCM's logs you want displayed in the debug console
	
	- **None**: No log will be shown. Recommended for production environments.
	- **Error**: Only warnings and errors. Recommended for develop environments.
	- **Info**: Errors and relevant information. Recommended for testing OCM integration.
	- **Debug**: Request and Responses to OCM's server will be displayed. Not recommended to use, only for debugging OCM.
	*/
	open var logLevel: LogLevel {
		didSet {
			LogManager.shared.logLevel = self.logLevel
		}
	}
	
	open var delegate: OCMDelegate?
	open var analytics: OCMAnalytics?
	
	
	open var host: String {
		didSet {
			Config.Host = self.host
		}
	}
	
	open var countryCode: String {
		didSet {
			Config.CountryCode = self.countryCode
		}
	}
	
	open var appVersion: String {
		didSet {
			Config.AppVersion = self.appVersion
		}
	}
	
	open var palette: OCMPalette? {
		didSet {
			Config.Palette = self.palette
		}
	}
	
	open var placeholder: UIImage? {
		didSet {
			Config.placeholder = self.placeholder
		}
	}
	
	open var noContentImage: UIImage? {
		didSet {
			Config.noContentImage = self.noContentImage
		}
	}
	
	fileprivate let wireframe = Wireframe(
		application: Application()
	)
	
	
	init() {
		self.logLevel = .none
		LogManager.shared.appName = "OCM"
		self.host = ""
		self.countryCode = ""
		self.appVersion = ""
		self.placeholder = nil
	}
	
	
	/**
	Retrieve the widget list view controller
	
	Use it to present this view to your users
	
	- returns: ViewController to be presented
	
	- Since: 1.0
	*/
	open func widgetList() -> UIViewController {
		return self.wireframe.widgetList()
	}
	
	/**
	Retrieve the widget list view controller
	
	Use it to present this view to your users
	
	- returns: ViewController to be presented
	
	- Since: 1.0
	*/
	open func notificationReceived(_ notification: [AnyHashable : Any]) {
		PushInteractor().pushReceived(notification)
	}
	
	/**
	Run the action of a widget
	
	**Discussion:** It will be executed only if was previously loaded.
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter widgetId: The widget identifier to run
	
	- Since: 1.0
	*/
	open func openWidget(_ widgetId: String) {
		let widgetInteractor = WidgetInteractor(
			storage: Storage.shared
		)
		
		widgetInteractor.openWidget(widgetId)
	}
}

public protocol OCMDelegate {
	func openCoupons()
	func openCoupon(_ id: String)
	func customScheme(_ url: URLComponents)
	func sessionExpired()
}

public protocol OCMAnalytics {
	func trackEvent(_ eventName: String)
}
    
