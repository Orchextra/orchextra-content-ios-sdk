//
//  Config.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class Config {
    
    static var Host = ""
    static var AppVersion = ""
    
    static var thumbnailEnabled: Bool = true
    
    @available(*, deprecated: 1.1.5, message: "use styles.placehold property instead")
    static var placeholder: UIImage?
    @available(*, deprecated: 1.1.5, message: "use contentListStyles.cellMarginsColor property instead")
    static var contentListMarginsColor: UIColor? = .white
    @available(*, deprecated: 1.1.5, message: "use contentListStyles.backgroundColor property instead")
    static var contentListBackgroundColor: UIColor? = .groupTableViewBackground
    
    static var loadingView: StatusView?
    static var noContentView: StatusView?
    static var noSearchResultView: StatusView?
    static var blockedContentView: StatusView?
    static var newContentsAvailableView: StatusView?
    
    @available(*, deprecated: 1.1.5, message: "use styles.primaryColor property instead")
    static var primaryColor: UIColor = .blue
    @available(*, deprecated: 1.1.5, message: "use styles.secondaryColor property instead")
    static var secondaryColor: UIColor = .white

    @available(*, deprecated: 1.1.5, message: "use contentNavigationBarStyles.type property instead")
    static var navigationType: NavigationType = .button
    @available(*, deprecated: 1.1.5, message: "use contentNavigationBarStyles.backgroundImage property instead")
    static var navigationBarBackgroundImage: UIImage?
    @available(*, deprecated: 1.1.5, message: "use contentNavigationBarStyles.buttonBackgroundImage property instead")
    static var navigationButtonBackgroundImage: UIImage?
    
    @available(*, deprecated: 1.1.5, message: "use contentListStyles.transitionBackgroundImage property instead")
    static var navigationTransitionBackgroundImage: UIImage?
    
    static var styles = Styles()
    static var contentListStyles = ContentListStyles()
    static var contentListCarouselLayoutStyles = ContentListCarouselLayoutStyles()
    static var contentNavigationBarStyles = ContentNavigationBarStyles()
    static var strings = Strings()
    static var providers = Providers()
    
    static var errorView: ErrorView?
    static var isLogged: Bool = false
    
    static var backgroundSessionCompletionHandler: (() -> Void)?
    static var isOrchextraRunning: Bool = false
    static var offlineSupportConfig: OfflineSupportConfig?
    static var resetLocalStorageWebView: Bool = false
    
    class func languageCode() -> String {
        return Locale.currentLanguageCode()
    }
    
	static var SDKVersion: String {
		let bundle = Bundle.OCMBundle()
        let sdkVersion: String? = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        let versionNumber = sdkVersion ?? "1.0.1" // To avoid problems in production
		let version = "IOS_\(versionNumber)"
		return version
	}
}
