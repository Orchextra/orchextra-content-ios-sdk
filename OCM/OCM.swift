//
//  OCM.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
import Orchextra

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
     Delegate for handling the behaviour of contents with custom properties.
     - Since: 2.1.??? // !!! Set version: current version is 2.1.7
     */
    public var customBehaviourDelegate: OCMCustomBehaviourDelegate?
    
    /**
     Delegate for OCM events. Use it to track or handle events of interest.
     
     - Since: 2.1
     */
    public var eventDelegate: OCMEventDelegate?
	
    /**
     Delegate for video OCM events. Use it to track when a video is played or stopped
     - Since: 2.1.4
     */
    public var videoEventDelegate: OCMVideoEventDelegate?
    
    /// Delegate for customize the values for the parameters associated to an action
    /// - Since: 3.0.0
    public var parameterCustomizationDelegate: OCMParameterCustomizationDelegate?
    
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
    
    /**
     Orchextra host. Use it to set Orchextra's environment.
     
     - Since: 1.1.14
     */
    public var orchextraHost: Environment? {
        didSet {
            if let orchextraHost = self.orchextraHost {
                OrchextraWrapper.shared.setEnvironment(host: orchextraHost)
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
                OrchextraWrapper.shared.set(businessUnit: businessUnit) {}
            }
        }
    }
    
    /**
     Use it to check if user is logged.
     
     - Since: 1.0
     */
    public var isLogged: Bool {
        return Config.isLogged
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
     Use it to set the language code. It will be sent to server to get content in this language if it is available.
     
     - Since: 1.0
     */
    public var languageCode: String? {
        didSet {
            Session.shared.languageCode = self.languageCode
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
     Use it to enable or disable OCM's offline support. When it's set the number of elements that are stored locally can be customized. If set nil, offline support is disabled. It must be set before start OCM's execution
     - Since: 2.1.3
     - See: func resetCache() to delete all cache generated.
     - See: OfflineSupportConfig
     */
    public var offlineSupportConfig: OfflineSupportConfig? {
        didSet {
            guard !Config.isOrchextraRunning else { return }
            if offlineSupportConfig == nil {
                resetCache()
            }
            Config.offlineSupportConfig = offlineSupportConfig
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
     Use it to set an error view that will be shown when an error occurs.
     
     - Since: 2.0.10
     */
    public var errorView: ErrorView? {
        didSet {
            Config.errorView = self.errorView
        }
    }
    
    /**
     Use this class to set credentials for OCM's integrated services and providers.
     
     - Since: 2.1.0
     */
    
    public var providers: Providers? {
        didSet {
            if let providers = self.providers {
                Config.providers = providers
            }
        }
    }
    
    /// Use it to start the OCM SDK. You have to provide the API key & API secret of the [Orchextra Dashboard](http://dashboard.orchextra.io) (by going to "Settings" > "SDK Configuration")
    ///
    /// - Parameters:
    ///   - apiKey: API Key of your project
    ///   - apiSecret: API Secret of your project
    ///   - completion: Block that returns the data result of the start operation
    ///   - Since: 2.0.0
    public func start(apiKey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        OCMController.shared.start(apiKey: apiKey, apiSecret: apiSecret, completion: completion)
    }
    
    /**
     Retrieve the section list
     
     Use it to build a dynamic menu in your app. The response will be notified by menusDidRefresh(_ menus: [Menu]) method.
     
     - Since: 2.0.0
     */
    public func loadMenus() {
        OCMController.shared.loadMenus()
    }
    
    /**
     Retrieve a SearchViewController
     
     Use it to show and search contents
     
     - returns: OrchextraViewController
     
     - Since: 1.0
     */
    public func searchViewController() -> OrchextraViewController? {
        return OCMController.shared.searchViewController()
    }
    
    /**
     Run the action with an identifier.
     
     Use it to run actions programatically (for example it can be triggered with an application url scheme)
     
     - parameter identifier: The identifier of the action
     - parameter completion: The block to be executed after action is open.
     
     - Since: 3.0.0
     */
    public func performAction(with identifier: String, completion: @escaping (UIViewController?) -> Void) {
        OCMController.shared.performAction(with: identifier, completion: completion)
    }
    
    /// Use this method to open a scanner
    ///
    /// - Parameter completion: returns the information of the scanned code
    public func scan(_ completion: @escaping (ScannerResult?) -> Void) {
        OCMController.shared.scan(completion)
    }
    
    /// Return the OCM access token
    ///
    /// - Returns: The access token stirng if exist
    public func accessToken() -> String? {
        return OrchextraWrapper.shared.loadAccessToken()
    }
    
    /**
     Updates local storage information.
     
     Use it set it in web view content that requires login access.
     
     - parameter localStorage: The local storage information to be stored.
     - Since: 1.0
     */
    public func update(localStorage: [AnyHashable: Any]?) {
        OCMController.shared.update(localStorage: localStorage)
    }
    
    /**
     Use it to reset the cache (content and images) generated by SDK, and clean it. It also cancel all current active requests in order to prevent content caching after deleting it.
     
     - Since: 1.2.0
     */
    public func resetCache() {
        OCMController.shared.resetCache()
    }
    
    /**
     Use it to reset the localStorage of WebView
     
     - Since: 2.0.14
     */
    public func isResetLocalStorageWebView(reset: Bool) {
        OCMController.shared.isResetLocalStorageWebView(reset: reset)
    }
    
    /// Use it to login into Orchextra environment. When the login process did finish, you will be notified in completion
    ///
    /// - Parameter userID: The identifier of the user that did login
    ///   completion: Return when finishes login
    /// - Since: 3.0.0
    public func didLogin(with userID: String, completion: @escaping () -> Void) {
        OCMController.shared.didLogin(with: userID, completion: completion)
    }
    
    /// Use it to logout into Orchextra environment. When the logout process did finish, you will be notified in completion.
    ///
    /// - Parameter completion: Return when finishes login
    /// - Since: 3.0.0
    public func didLogout(completion: @escaping () -> Void) {
        OCMController.shared.didLogout(completion: completion)
    }
    
    /**
     Use this method to notify the app is about to transition from the background to the active state.

     - Since: 2.1.1
     */
    public func applicationWillEnterForeground() {
        OCMController.shared.applicationWillEnterForeground()
    }
    
    
    /// Use it to set the bussines units
    ///
    /// - Parameters:
    ///   - businessUnits: An array of business units
    ///   - completion: completion to notify when the process did finish
    public func set(businessUnit: String, completion: @escaping () -> Void) {
        OrchextraWrapper.shared.set(businessUnit: businessUnit, completion: completion)
    }
    
    
    /// Default init
    internal convenience override init() {
        self.init(wireframe: Wireframe(application: Application()))
    }
    
    internal init(wireframe: OCMWireframe) {
        self.logLevel = .none
        self.orchextraHost = .staging
        LogManager.shared.appName = "OCM"
        self.host = ""
        self.thumbnailEnabled = true
        super.init()
        OCMController.shared.loadWireframe(wireframe: wireframe)
        OCMController.shared.loadFonts()
    }
}
