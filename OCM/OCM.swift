//
//  OCM.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

//swiftlint:disable file_length

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
	
    /**
      OCM Singleton instance
     
     - Since: 1.0
     */
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
      The OCM delegate. Use it to communicate with integrative application.
     
     - Since: 1.0
     */
	public var delegate: OCMDelegate?
    
    /**
     The analytics delegate. Use it to launch an analytic tracking.
     
     - Since: 1.0
     */
	public var analytics: OCMAnalytics?
	//swiftlint:enable weak_delegate
	
	/**
     The content manager host. Use it to point to different environment.
     
     - Since: 1.0
    */
	public var host: String {
		didSet {
			Config.Host = self.host
		}
	}
    
    // TODO: Set version for this new property !!!
    /**
     Orchextra host. Use it to set Orchextra's environment.
     
     - Since: 1.???
     */
    public var orchextraHost: String? {
        didSet {
            if let orchextraHost = self.orchextraHost {
                OrchextraWrapper.shared.setEnvironment(host: orchextraHost)
            }
        }
    }
    
    /**
     Use it to set Orchextra device business unit
     
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
      Use it to set Orchextra device business unit
     
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
     Use it to log into Orchextra Core.
     
     - Since: 1.0
     */
	public var userID: String? {
		didSet {
			OrchextraWrapper.shared.bindUser(with: userID)
		}
	}
    
    /**
      Use it to check if user is logged.
     
     - Since: 1.0
     */
    public var isLogged: Bool {
        didSet {
            Config.isLogged = self.isLogged
        }
    }
    
    /**
     Use it to set the completion handler for image caching background tasks. This handler is provided by 
     UIAppDelegate's application(_:handleEventsForBackgroundURLSession:completionHandler). 
          
     - Since: 1.1.9
     */
    public var backgroundSessionCompletionHandler: (() -> Void)? {
        didSet {
            Config.backgroundSessionCompletionHandler = self.backgroundSessionCompletionHandler
        }
    }
	
    /**
      Use it to set a preview that is shown while asynchronous image is loading.
     
     - Warning: This property is **deprecated**. Set `placeholderImage` for `styles` property instead
     
     - Since: 1.0
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set placeholderImage for styles property instead")
	public var placeholder: UIImage? {
		didSet {
			Config.placeholder = self.placeholder
		}
    }
    
    /**
     Use it to configure if we want to show the default image thumbnail while it is loading (Default if true).
     
     - Since: 1.1.5
     */
    public var thumbnailEnabled: Bool {
        didSet {
            Config.thumbnailEnabled = self.thumbnailEnabled
        }
    }
    
    /**
     Use it to set an image wich indicates that content is blocked.
     
     - Since: 1.0
    */
    public var blockedContentView: StatusView? {
        didSet {
            Config.blockedContentView = self.blockedContentView
        }
    }
	
    /**
     Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
     
     - Since: 1.0
     */
    public var loadingView: StatusView? {
        didSet {
            Config.loadingView = self.loadingView
        }
    }
    
    /**
     Use it to set a view that will be show when new content is available.
     
     - Since: 2.0
     */
    public var newContentsAvailableView: StatusView? {
        didSet {
            Config.newContentsAvailableView = self.newContentsAvailableView
        }
    }
    
    /**
      Use it to set a content list background color. It allows avoid whitespaces by using application custom color.
     
     - Warning: This property is **deprecated**. Set `backgroundColor` for `contentListStyles` instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set backgroundColor for contentListStyles property instead")
    public var contentListBackgroundColor: UIColor? {
        didSet {
            Config.contentListBackgroundColor = self.contentListBackgroundColor
        }
    }
    
    /**
     Use it to set a content list margin color.
     
     - Warning: This property is **deprecated**. Set `cellMarginsColor` for `contentListStyles` instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set cellMarginsColor for contentListStyles property instead")
    public var contentListMarginsColor: UIColor? {
        didSet {
            Config.contentListMarginsColor = self.contentListMarginsColor
        }
    }
    
    /**
     Use it to set a custom view that will be shown when there will be no content.
     
     - Since: 1.0
     */
	public var noContentView: StatusView? {
		didSet {
			Config.noContentView = self.noContentView
		}
	}
	
    /**
     Use it to set a custom view that will be shown when there will be no content associated to a search.
     
     - Since: 1.0
     */
    public var noSearchResultView: StatusView? {
        didSet {
            Config.noSearchResultView = self.noSearchResultView
        }
    }
    
    /**
     Use it to instantiate ErrorView clasess that will be shown when an error occurs.
     
     - Since: 1.0
     */
    public var errorViewInstantiator: ErrorView.Type? {
        didSet {
            Config.errorView = self.errorViewInstantiator
        }
    }
    
    /**
    Use it to set a language code. It will be sent to server to get content in this language if it is available.
     
     - Since: 1.0
     */
    public var languageCode: String? {
        didSet {
            Session.shared.languageCode = self.languageCode
        }
    }
    
    /**
     Use it to set the the type of controls displayed for content navigation.
     
     - **button**: Buttons for navigation.
     - **navigationBar**: Navigation bar on top for navigation.
     
     - Warning: This property is **deprecated**. Set `type` for `contentNavigationBarStyles` instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set type for contentNavigationBarStyles property instead")
    public var navigationType: NavigationType? {
        didSet {
            if let navigationType = self.navigationType {
                Config.navigationType = navigationType
            }
        }
    }
    
    /**
     Use it to set the primary color of UI controls, this property sets up the following properties:
     
     - Navigation buttons background color
     - Navigation bar background color
     - Page control's active page indicator
     
     - Warning: This property is **deprecated**. Set `primaryColor` for `styles`property instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set primaryColor for styles property instead")
    public var primaryColor: UIColor? {
        didSet {
            if let primaryColor = self.primaryColor {
                Config.primaryColor = primaryColor
            }
        }
    }
    
    /**
     Use it to set the background color of UI controls, this property sets up the following properties:
     
     - Navigation buttons tint color
     - Navigation bar tint color
     - Page control's inactive page indicator
     
     - Warning: This property is **deprecated**. Set `secondaryColor` for `styles` property instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set secondaryColor for styles property instead")
    public var secondaryColor: UIColor? {
        didSet {
            if let secondaryColor = self.secondaryColor {
                Config.secondaryColor = secondaryColor
            }
        }
    }
    
    /**
     Use it to set a background image for the content navigation bar.
     If not defined, the navigation bar background will use the 'primaryColor'
     
     - Warning: This property is **deprecated**. Set `barBackgroundImage` for `contentNavigationBarStyles` property instead

     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set barBackgroundImage for contentNavigationBarStyles property instead")
    public var navigationBarBackgroundImage: UIImage? {
        didSet {
            Config.navigationBarBackgroundImage = self.navigationBarBackgroundImage
        }
    }
    
    /**
     Use it to set a background image for the content navigation buttons.
     If not defined, the navigation button background will use the 'primaryColor'
     
     - Warning: This property is **deprecated**. Set `buttonBackgroundImage` for `contentNavigationBarStyles` property instead
     
     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set buttonBackgroundImage for contentNavigationBarStyles property instead")
    public var navigationButtonBackgroundImage: UIImage? {
        didSet {
            Config.navigationButtonBackgroundImage = self.navigationButtonBackgroundImage
        }
    }
    
    /**
     Use it to set a background image for the navigation transition to a content detail.
     If not defined, the transition will use the 'contentListStyles.transitionBackgroundImage'
     
     - Warning: This property is **deprecated**. Set `transitionBackgroundImage` for `contentListStyles` property instead

     - Since: 1.1.1
     - Version: 1.1.7
     */
    @available(*, deprecated: 1.1.7, message: "set transitionBackgroundImage for contentListStyles property instead")
    public var navigationTransitionBackgroundImage: UIImage? {
        didSet {
            Config.navigationTransitionBackgroundImage = self.navigationTransitionBackgroundImage
        }
    }
    
    /**
     Use it to customize style properties for UI controls and other components.
     - Since: 1.1.7
     */
    public var styles: Styles? {
        didSet {
            if let styles = self.styles {
                Config.styles = styles
            }
        }
    }
    
    /**
     Use it to customize style properties for the Content List.
     - Since: 1.1.7
     */
    public var contentListStyles: ContentListStyles? {
        didSet {
            if let contentListStyles = self.contentListStyles {
                Config.contentListStyles = contentListStyles
            }
        }
    }
    
    /**
     Use it to customize style properties for the Content List with a carousel layout.
     - Since: 1.1.7
     */
    public var contentListCarouselLayoutStyles: ContentListCarouselLayoutStyles? {
        didSet {
            if let contentListCarouselLayoutStyles = self.contentListCarouselLayoutStyles {
                Config.contentListCarouselLayoutStyles = contentListCarouselLayoutStyles
            }
        }
    }
    
    /**
     Use it to customize style properties for the Content Detail navigation bar.
     - Since: 1.1.7
     */
    public var contentNavigationBarStyles: ContentNavigationBarStyles? {
        didSet {
            if let contentNavigationBarStyles = self.contentNavigationBarStyles {
                Config.contentNavigationBarStyles = contentNavigationBarStyles
            }
        }
    }
    
    /**
     Use it to customize string properties.
     - Since: 2.0.0
    */
    public var strings: Strings? {
        didSet {
            if let strings = self.strings {
                Config.strings = strings
            }
        }
    }
    
    /**
     Use it to set the offline support. When you set it to true, several data will be save in order to improve performance.
     - Since: 1.2.0
     - Seealso: func resetCache() to delete all cache generated.
    */
    public var offlineSupport: Bool = false {
        didSet {
            if !offlineSupport {
                resetCache()
            }
            Config.offlineSupport = offlineSupport
        }
    }
    
    internal let wireframe = Wireframe(
        application: Application()
    )
    
    /**
     Initializes an OCM instance.
     
     - Since: 1.0
     */
	override init() {
		self.logLevel = .none
		LogManager.shared.appName = "OCM"
		self.host = ""
        self.isLogged = false
        self.thumbnailEnabled = true
        super.init()
        self.loadFonts()
	}
    
    // TODO: Add proper documentation and link to version
    /**
     Add documentation.
     
     - Since: 1.?
     */
    public func start(apiKey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        OrchextraWrapper.shared.startWith(apikey: apiKey, apiSecret: apiSecret, completion: completion)    
    }
	
	/**
	Retrieve the section list
	
	Use it to build a dynamic menu in your app
	
    - parameter completionHandler: Block of code that will be executed after menus are created.
	- returns: Dictionary of sections to be represented
	
	- Since: 1.0
	*/
//    @available(*, deprecated: 2.0.0, message: "use loadMenus() instead", renamed: "loadMenus()")
//	public func menus(completionHandler: @escaping (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void) {
//        MenuCoordinator.shared.menus(completion: completionHandler)
//	}
    
    /**
     Retrieve the section list
     
     Use it to build a dynamic menu in your app. The response will be notified by menusDidRefresh(_ menus: [Menu]) method.
     
     - Since: 2.0.0
     */
    public func loadMenus() {
        MenuCoordinator.shared.loadMenus()
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
	Run the action with an identifier.
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter identifier: The identifier of the action
    - parameter completion: The block to be executed after action is open.
	
	- Since: 1.0
	*/
    public func openAction(with identifier: String, completion: @escaping (UIViewController?) -> Void) {
        let actionInteractor = ActionInteractor(
            contentDataManager: .sharedDataManager
        )
        actionInteractor.action(with: identifier, completion: { action, _ in
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
    @available(*, deprecated: 2.0.0, message: "use update: instead", renamed: "update")
    public func updateLocalStorage(localStorage: [AnyHashable : Any]?) {
        Session.shared.localStorage = localStorage
    }

    
    /**
     Updates local storage information.
     
     Use it set it in web view content that requires login access.
     
     - parameter localStorage: The local storage information to be stored.
     - Since: 1.0
     */
    public func update(localStorage: [AnyHashable : Any]?) {
        Session.shared.localStorage = localStorage
    }
    
    /**
     Use it to reset the cache (content and images) generated by SDK, and clean it.
     
     - Since: 1.2.0
     */
    public func resetCache() {
        ContentCoreDataPersister.shared.cleanDataBase()
        ContentCacheManager.shared.resetCache()
    }
	
	// MARK: - Private Helpers
    private func loadFonts() {
        UIFont.loadSDKFont(fromFile: "gotham-ultra.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-medium.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-light.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-book.ttf")
    }
}


/**
 This protocol is used to mark some views in the application that indicate a state (such as no results found after a search, loading content or content that requires login to be shown).
 
 - Since: 1.0
 */
public protocol StatusView {
    
    /**
      Use this method to instantiate a view that implements this protocol.
     
     - Since: 1.0
     */
    func instantiate() -> UIView
}

/**
 This protocol is used to mark some views in the application that indicate an error.
 
 - Since: 1.0
 */
public protocol ErrorView {
    
    /**
     Use this method to instantiate a view that implements this protocol.
     
     - Since: 1.0
     */
    static func instantiate() -> ErrorView
    
    /**
     Use this method to set the error description. This allow to manage error information inside the error view.
     
     - Since: 1.0
     */
    func set(errorDescription: String)
    
    /**
     Use this method to provide a block of code that will be executed after user retries the operation that previously falied.
     
     - Since: 1.0
     */
    func set(retryBlock: @escaping () -> Void)
    
    /*
     Returns a view wich indicates that an error has been occured
     
     - returns: The error view.
     
     - Since: 1.0
     */
    func view() -> UIView
}

//swiftlint:disable class_delegate_protocol

/**
 This protocol is used to comunicate OCM with integrative application.
 
 - Since: 1.0
 */
public protocol OCMDelegate {
    
    /**
     Use this method to execute a custom action associated to an url.
     
     - parameter url: The url to be launched.
     - Since: 1.0
     */
	func customScheme(_ url: URLComponents)
    
    /**
     Use this method to indicate that some content requires authentication.
     
     - Since: 1.0
     */
    func requiredUserAuthentication()
    
    /**
     Use this method to notify that access token has been updated.
     
     - parameter accessToken: The new access token.
     - Since: 1.0
     */
    func didUpdate(accessToken: String?)
    
    /**
     Use this method to notify that Passbook has returned an error.
     
     - parameter error: The passbook error.
     - Since: 1.0
     */
    @available(*, deprecated: 1.0.7, message: "Unused method")
    func showPassbook(error: PassbookError)
    
    /**
     Use this method to notify that content has been opened.
     
     - parameter identifier: The content identifier that has been opened.
     - Since: 1.0
     */
    func userDidOpenContent(with identifier: String)
    
    /**
     Use this method to notify that menus has been updated.
     
     - Parameter menus: The menus
     - Since: 2.0.0
    */
    func menusDidRefresh(_ menus: [Menu])
}
//swiftlint:enable class_delegate_protocol

/**
 This protocol is used to track information in analytics framweworks.
 
 - Since: 1.0
 */
public protocol OCMAnalytics {
    
    /**
     Use this method to track an event in analytics framworks.
     
     - parameter info: The info to be tracked.
     - Since: 1.0
     */
    func track(with info: [String: Any?])
    
//swiftlint:enable file_legth
}
