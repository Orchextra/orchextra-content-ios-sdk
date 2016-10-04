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
public class OCM {
	
	public static let shared = OCM()
	
	/**
	Type of OCM's logs you want displayed in the debug console
	
	- **None**: No log will be shown. Recommended for production environments.
	- **Error**: Only warnings and errors. Recommended for develop environments.
	- **Info**: Errors and relevant information. Recommended for testing OCM integration.
	- **Debug**: Request and Responses to OCM's server will be displayed. Not recommended to use, only for debugging OCM.
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
	
	public var noContentImage: UIImage? {
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
	Retrieve the section list
	
	Use it to build a dynamic menú in your app
	
	- returns: Array of section to be represented
	
	- Since: 1.0
	*/
	public func sectionList() -> [Section] {
		return [
			Section(name: "All"),
			Section(name: "Events"),
			Section(name: "Articles"),
			Section(name: "Videos"),
			Section(name: "Vaya tio"),
			Section(name: "el Sergio López")
		]
	}
	
	
	/**
	Retrieve the content list view controller
	
	Use it to present this view to your users
	
	- returns: ViewController to be presented
	
	- Since: 1.0
	*/
	public func contentList() -> UIViewController {
		return self.wireframe.contentList()
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
	
	/**
	Run the action of a content
	
	**Discussion:** It will be executed only if was previously loaded.
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter contentId: The content identifier to run
	
	- Since: 1.0
	*/
	public func openContent(_ contentId: String) {
		let contentInteractor = ContentInteractor(
			storage: Storage.shared
		)
		
		contentInteractor.openContent(contentId)
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
    
