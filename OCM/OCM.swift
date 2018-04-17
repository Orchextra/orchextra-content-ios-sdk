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

/// The OCM class provides you with methods for starting the framework and retrieve the ViewControllers to use within your app.
///
/// ### Usage
/// You should use the `shared` property to get a unique singleton instance and then set all the properties you want to customize.
///
/// ### Overview
/// Once the framework is started, you can retrieve the contents to display in your app.
///
/// - Since: 1.0
/// - Version: 3.0
/// - Author: Alejandro Jiménez Agudo
/// - Copyright: Gigigo S.L.
open class OCM: NSObject {
    
    /// OCM Singleton instance
    ///
    /// - Since: 1.0
    public static let shared = OCM()
    
    // MARK: - Delegates
    
    //swiftlint:disable weak_delegate
    
    /// Delegate for reacting to changes in the content handled by OCM.
    ///
    /// - Since: 3.0
    public var contentDelegate: ContentDelegate?
    
    /// Delegate for federated authentication.
    ///
    /// - Since: 3.0
    public var federatedAuthenticationDelegate: FederatedAuthenticationDelegate?
    
    /// Delegate for handling a scheme URL triggered in OCM.
    ///
    /// - Since: 3.0
    public var schemeDelegate: URLSchemeDelegate?
    
    /// Delegate for handling the behaviour of contents with custom properties.
    ///
    /// - Since: 2.1.8
    public var customBehaviourDelegate: CustomBehaviourDelegate?
    
    /// Delegate for OCM events. Use it to track or handle events of interest.
    ///
    /// - Since: 2.1
    public var eventDelegate: EventDelegate?
    
    /// Delegate for video OCM events. Use it to track when a video is played or stopped.
    ///
    /// - Since: 2.1.4
    public var videoEventDelegate: VideoEventDelegate?
    
    /// Delegate to customize the views that OCM displays
    ///
    /// - Since: 3.0.0
    public var customViewDelegate: CustomViewDelegate?
    
    /// Delegate for customize the values for the parameters associated to an action
    ///
    /// - Since: 2.5.0
    public var parameterCustomizationDelegate: ParameterCustomizationDelegate?
    
    //swiftlint:enable weak_delegate
    
    // MARK: - Public properties
    
    ///  Type of OCM's logs you want displayed in the debug console
    ///
    ///  - **none**: No log will be shown. Recommended for production environments.
    ///  - **error**: Only warnings and errors. Recommended for develop environments.
    ///  - **info**: Errors and relevant information. Recommended for testing OCM integration.
    ///  - **debug**: Request and Responses to OCM's server will be displayed. Not recommended to use, only for debugging OCM.
    ///
    /// - Since: 1.0

    public var logLevel: LogLevel {
        didSet {
            LogManager.shared.logLevel = self.logLevel
        }
    }
    
    /// Use it to set the OCM's environment
    ///
    /// - Since: 3.0.0
    public var environment: OCMSDK.Environment {
        didSet {
            switch self.environment {
            case .staging:
                Config.Host = "https://cm.s.orchextra.io"
            case .quality:
                Config.Host = "https://cm.q.orchextra.io"
            case .production:
                Config.Host = "https://cm.orchextra.io"
            }
            OrchextraWrapper.shared.setEnvironment(host: self.environment)
        }
    }
    
    /// Use it to set Orchextra device business unit
    ///
    /// - Since: 2.0
    public var businessUnit: String? {
        didSet {
            if let businessUnit = self.businessUnit {
                OrchextraWrapper.shared.set(businessUnit: businessUnit) {}
            }
        }
    }
    
    /// Use it to check if user is logged.
    ///
    /// - Since: 1.0
    public var isLogged: Bool {
        return Config.isLogged
    }
    
    /// Use it to set the completion handler for image caching background tasks. This handler is provided by
    /// UIAppDelegate's application(_:handleEventsForBackgroundURLSession:completionHandler).
    ///
    /// - Since: 1.1.9
    public var backgroundSessionCompletionHandler: (() -> Void)? {
        didSet {
            Config.backgroundSessionCompletionHandler = self.backgroundSessionCompletionHandler
        }
    }
    
    /// Use it to configure if we want to show the default image thumbnail while it is loading (Default if true).
    ///
    /// - Since: 1.1.5
    public var thumbnailEnabled: Bool {
        didSet {
            Config.thumbnailEnabled = self.thumbnailEnabled
        }
    }
    
    /// Use it to set the language code. It will be sent to server to get content in this language if it is available.
    ///
    /// - Since: 1.0
    public var languageCode: String? {
        didSet {
            Session.shared.languageCode = self.languageCode
        }
    }
    
    /// Use it to customize style properties for UI controls and other components.
    ///
    /// - Since: 1.1.7
    public var styles: Styles? {
        didSet {
            if let styles = self.styles {
                Config.styles = styles
            }
        }
    }
    
    /// Use it to customize style properties for the Content List.
    ///
    /// - Since: 1.1.7
    public var contentListStyles: ContentListStyles? {
        didSet {
            if let contentListStyles = self.contentListStyles {
                Config.contentListStyles = contentListStyles
            }
        }
    }
    
    /// Use it to customize style properties for the Content List with a carousel layout.
    ///
    /// - Since: 1.1.7
    public var contentListCarouselLayoutStyles: ContentListCarouselLayoutStyles? {
        didSet {
            if let contentListCarouselLayoutStyles = self.contentListCarouselLayoutStyles {
                Config.contentListCarouselLayoutStyles = contentListCarouselLayoutStyles
            }
        }
    }
    
    /// Use it to customize style properties for the Content Detail navigation bar.
    ///
    /// - Since: 1.1.7
    public var contentNavigationBarStyles: ContentNavigationBarStyles? {
        didSet {
            if let contentNavigationBarStyles = self.contentNavigationBarStyles {
                Config.contentNavigationBarStyles = contentNavigationBarStyles
            }
        }
    }
    
    /// Use it to enable or disable OCM's offline support. When it's set the number of elements that are stored locally can be customized. If set nil, offline support is disabled. It must be set before start OCM's execution
    ///
    /// - Since: 2.1.3
    /// - See: func resetCache() to delete all generated cache.
    /// - See: OfflineSupportConfig
    public var offlineSupportConfig: OfflineSupportConfig? {
        didSet {
            guard !Config.isOrchextraRunning else { return }
            if offlineSupportConfig == nil {
                resetCache()
            }
            Config.offlineSupportConfig = offlineSupportConfig
        }
    }
    
    /// Use it to enable pagination in requests of content
    /// - Since: 2.4.0
    public var paginationConfig: PaginationConfig? {
        didSet {
            if !Config.isOrchextraRunning {
                Config.paginationConfig = self.paginationConfig
            } else {
                logWarn("Pagination should be configured before starting OCM")
            }
        }
    }
    
    /// Use it to customize string properties.
    ///
    /// - Since: 2.0.0
    public var strings: Strings? {
        didSet {
            if let strings = self.strings {
                Config.strings = strings
            }
        }
    }
    
    /// Use this class to set credentials for OCM's integrated services and providers.
    ///
    /// - Since: 2.1.0
    public var providers: Providers? {
        didSet {
            if let providers = self.providers {
                Config.providers = providers
            }
        }
    }
    
    // MARK: - Public methods
    
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
    
    /// Retrieve the section list
    /// Use it to build a dynamic menu in your app. The response will be notified by menusDidRefresh(_ menus: [Menu]) method.
    ///
    /// - Since: 2.0.0
    public func loadMenus() {
        OCMController.shared.loadMenus()
    }
    
    /// Returns a search view controller
    ///
    /// - Returns: SearchVC
    ///
    /// - Since: 1.0
    public func searchViewController() -> SearchVC? {
    return SearchWireframe().loadSearchVC()
    }
    
    /// Run the action with an identifier.
    /// Use it to run actions programatically (for example it can be triggered with an application url scheme).
    ///
    /// - parameter identifier: The identifier of the action.
    /// - parameter completion: The block to be executed after action is open.
    ///
    /// - Since: 3.0.0
    public func performAction(with identifier: String, completion: @escaping (UIViewController?) -> Void) {
        OCMController.shared.performAction(with: identifier, completion: completion)
    }
    
    /// Use this method to open a scanner.
    ///
    /// - Parameter completion: returns the information of the scanned code.
    ///
    /// - Since: 3.0.0
    public func scan(_ completion: @escaping (ScannerResult?) -> Void) {
        OCMController.shared.scan(completion)
    }
    
    /// Use this method to open scanner for triggering Orchextra's actions.
    ///
    /// - Since: 3.0.0
    public func openScanner() {
        OrchextraWrapper.shared.startScanner()
    }
    
    /// Returns the OCM access token.
    ///
    /// - Returns: The access token stirng if exist.
    /// - Since: ?.?
    public func accessToken() -> String? {
        return OrchextraWrapper.shared.loadAccessToken()
    }
    
    /// Use this method to register APNS token for device in Orchextra
    ///
    /// - Since: 3.0.0
    public func registerDeviceForRemoteNotifications(deviceToken: Data) {
        OrchextraWrapper.shared.registerDeviceForRemoteNotifications(deviceToken: deviceToken)
    }
    
    /// Call this method for OCM to handle a remote notification
    ///
    /// - Since: 3.0.0
    public func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        OrchextraWrapper.shared.handleRemoteNotification(userInfo: userInfo)
    }

    /// Call this method for OCM to handle a local notification
    ///
    /// - Since: 3.0.0
    public func handleLocalNotification(userInfo: [AnyHashable: Any]) {
        OrchextraWrapper.shared.handleLocalNotification(userInfo: userInfo)
    }

    /// Updates local storage information.
    /// Use it for WebView content that requires user authentication.
    ///
    /// - parameter localStorage: The local storage information to be stored.
    /// - Since: 1.0
    public func update(localStorage: [AnyHashable: Any]?) {
        OCMController.shared.update(localStorage: localStorage)
    }
    
    /// Use it to reset the cache (content and images) generated by SDK, and clean it. It also cancel all current active requests in order to prevent content caching after deleting it.
    ///
    /// - Since: 1.2.0
    public func resetCache() {
        OCMController.shared.resetCache()
    }
        
    /// Use it to reset WebView local storage 
    ///
    /// - Since: 2.2.2
    public func resetWebViewLocalStorage() {
        OCMController.shared.removeLocalStorage()
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
    
    /// Use this method to notify the app is about to transition from the background to the active state.
    ///
    /// - Since: 2.1.1
    public func applicationWillEnterForeground() {
        OCMController.shared.applicationWillEnterForeground()
    }
    
    /// Use it to set the bussines units
    ///
    /// - Parameter businessUnits: An array of business units.
    /// - Parameter completion: completion to notify when the process did finish.
    public func set(businessUnit: String, completion: @escaping () -> Void) {
        OrchextraWrapper.shared.set(businessUnit: businessUnit, completion: completion)
    }
    
    // MARK: - Internal initializers
    
    internal convenience override init() {
        self.init(wireframe: Wireframe(application: Application()))
    }
    
    internal init(wireframe: OCMWireframe) {
        self.logLevel = .none
        self.environment = .staging
        LogManager.shared.appName = "OCM"
        self.thumbnailEnabled = true
        super.init()
        OCMController.shared.loadWireframe(wireframe: wireframe)
        OCMController.shared.loadFonts()
    }
}
