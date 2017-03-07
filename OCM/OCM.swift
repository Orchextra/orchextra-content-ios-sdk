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
	
	//swiftlint:disable weak_delegate
    /**
     * The OCM delegate. Use it to communicate with integrative application.
     *
     - Since: 1.0
     */
	public var delegate: OCMDelegate?
    
    /**
     * The analytics delegate. Use it to launch an analytic tracking.
     *
     - Since: 1.0
     */
	public var analytics: OCMAnalytics?
	//swiftlint:enable weak_delegate
	
	/**
     *The content manager host. Use it to point to different environment.
     *
     - Since: 1.0
    */
	public var host: String {
		didSet {
			Config.Host = self.host
		}
	}
    
    /**
     * Use it to set Orchextra device business unit
     *
     - Since: 1.0
     */
    @available(*, deprecated: 2.0, message: "use businessUnit: instead", renamed: "businessUnit")
    public var countryCode: String? {
        didSet {
            if let countryCode = self.countryCode {
                OrchextraWrapper.shared.setCountry(code: countryCode)
            }
        }
    }
    
    /**
     * Use it to set Orchextra device business unit
     *
     - Since: 2.0
     */
	public var businessUnit: String? {
		didSet {
			if let businessUnit = self.businessUnit {
				OrchextraWrapper.shared.set(businessUnit: businessUnit)
			}
		}
	}
	
    /**
     * Use it to log into Orchextra Core.
     *
     - Since: 1.0
     */
	public var userID: String? {
		didSet {
			OrchextraWrapper.shared.bindUser(with: userID)
		}
	}
    
    /**
     * Use it to check if user is logged.
     *
     - Since: 1.0
     */
    public var isLogged: Bool {
        didSet {
            Config.isLogged = self.isLogged
        }
    }
	
    /**
     * Use it to set a preview that is shown while asynchronous image is loading.
     *
     - Since: 1.0
     */
	public var placeholder: UIImage? {
		didSet {
			Config.placeholder = self.placeholder
		}
	}
    
    /**
     * Use it to set an image wich indicates that content is blocked.
     *
     - Since: 1.0
    */
    public var blockedContentView: StatusView? {
        didSet {
            Config.blockedContentView = self.blockedContentView
        }
    }
	
    /**
     * Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
     *
     - Since: 1.0
     */
    public var loadingView: StatusView? {
        didSet {
            Config.loadingView = self.loadingView
        }
    }
    
    /**
     * Use it to set a content list background color. It allows avoid whitespaces by using application custom color.
     *
     - Since: 1.0
     */
    public var contentListBackgroundColor: UIColor? {
        didSet {
            Config.contentListBackgroundColor = self.contentListBackgroundColor
        }
    }
    
    /**
     * Use it to set a content list margin color.
     *
     - Since: 1.0
     */
    public var contentListMarginsColor: UIColor? {
        didSet {
            Config.contentListMarginsColor = self.contentListMarginsColor
        }
    }
    
    /**
     * Use it to set a custom view that will be shown when there will be no content.
     *
     - Since: 1.0
     */
	public var noContentView: StatusView? {
		didSet {
			Config.noContentView = self.noContentView
		}
	}
	
    /**
     * Use it to set a custom view that will be shown when there will be no content associated to a search.
     *
     - Since: 1.0
     */
    public var noSearchResultView: StatusView? {
        didSet {
            Config.noSearchResultView = self.noSearchResultView
        }
    }
    
    /**
     * Use it to instantiate ErrorView clasess that will be shown when an error occurs.
     *
     - Since: 1.0
     */
    public var errorViewInstantiator: ErrorView.Type? {
        didSet {
            Config.errorView = self.errorViewInstantiator
        }
    }
    
    /**
     * Use it to set a language code. It will be sent to server to get content in this language if it is available.
     *
     - Since: 1.0
     */
    public var languageCode: String? {
        didSet {
            Session.shared.languageCode = self.languageCode
        }
    }
    
	internal let wireframe = Wireframe(
		application: Application()
	)
    
    /**
     * Initializes an OCM instance.
     *
     - Since: 1.0
     */
	override init() {
		self.logLevel = .none
		LogManager.shared.appName = "OCM"
		self.host = ""
		self.placeholder = nil
        self.isLogged = false
        
        super.init()
        self.loadFonts()
	}
	
	/**
	Retrieve the section list
	
	Use it to build a dynamic menu in your app
	
    - completionHandler: Block of code that will be executed after menus are created.
	- returns: Dictionary of sections to be represented
	
	- Since: 1.0
	*/
	public func menus(completionHandler: @escaping (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void) {
		MenuCoordinator(
            sessionInteractor: SessionInteractor(
                session: Session.shared,
                orchextra: OrchextraWrapper.shared
            )
        ).menus(completion:
			completionHandler)
	}
	
    /**
     Retrieve a SearchViewController
     
     Use it to show and search contents
     
     - returns: OrchextraViewController
     
     - Since: 1.0
     */
    public func searchViewController() -> OrchextraViewController? {
        return OCM.shared.wireframe.contentList()
    }
    
	/**
	Run the action with an id
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter id: The id of the action
    - parameter completion: The block to be executed after action is open.
	
	- Since: 1.0
	*/
    public func openAction(with id: String, completion: @escaping (UIViewController?) -> Void) {
        let actionInteractor = ActionInteractor(
            dataManager: ActionDataManager(
                storage: Storage.shared,
                elementService: ElementService()
            )
        )
        actionInteractor.action(with: id, completion: { action, _ in
            if let action = action {
                switch action {
                case is ActionYoutube:
                    completion(action.view())
                default:
                    completion(self.wireframe.provideMainComponent(with: action))
                }
            } else {
                completion(nil)
            }
        })
	}
    
    /**
     Updates local storage information
     
     Use it set it in web view content that requires login access.
     
     - parameter localStorage: The local storage information to be stored.
     - Since: 1.0
     */
     @available(*, deprecated: 2.0, message: "use update: instead", renamed: "update")
    public func updateLocalStorage(localStorage: [AnyHashable : Any]?) {
        Session.shared.localStorage = localStorage
    }

    
    /**
     Updates local storage information.
     
     Use it set it in web view content that requires login access.
     
     - parameter localStorage: The local storage information to be stored.
     - Since: 2.0
     */
    public func update(localStorage: [AnyHashable : Any]?) {
        Session.shared.localStorage = localStorage
    }
    
    /**
     Notifies the delegate that access token has been updated.
     
     Use it to perform actions that needs this token updated.
     
     - parameter accessToken: The new access token.
     - Since: 1.0
     */
	public func didUpdate(accessToken: String?) {
		self.delegate?.didUpdate(accessToken: accessToken)
	}
	
	
	// MARK: - Private Helpers
    private func loadFonts() {
        UIFont.loadSDKFont(fromFile: "gotham-ultra.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-medium.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-light.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-book.ttf")
    }
}

public protocol StatusView {
    func instantiate() -> UIView
}

public protocol ErrorView {
    static func instantiate() -> ErrorView
    func set(errorDescription: String)
    func set(retryBlock: @escaping () -> Void)
    func view() -> UIView
}

//swiftlint:disable class_delegate_protocol
public protocol OCMDelegate {
	func customScheme(_ url: URLComponents)
    func requiredUserAuthentication()
    func didUpdate(accessToken: String?)
    func showPassbook(error: PassbookError)
    func userDidOpenContent(with id: String)
}
//swiftlint:enable class_delegate_protocol

public protocol OCMAnalytics {
    func track(with info: [String: Any?])
}
