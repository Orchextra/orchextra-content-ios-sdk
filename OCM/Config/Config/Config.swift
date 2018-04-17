//
//  Config.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

public enum Environment {
    case staging
    case quality
    case production
}

class Config {
    
    static var Host = ""
    static var AppVersion = ""
    
    static var thumbnailEnabled: Bool = true
    
    static var styles = Styles()
    static var contentListStyles = ContentListStyles()
    static var contentListCarouselLayoutStyles = ContentListCarouselLayoutStyles()
    static var contentNavigationBarStyles = ContentNavigationBarStyles()
    static var strings = Strings()
    static var providers = Providers()
    
    static var isLogged: Bool = false
    
    static var backgroundSessionCompletionHandler: (() -> Void)?
    static var isOrchextraRunning: Bool = false
    static var offlineSupportConfig: OfflineSupportConfig?
    static var paginationConfig: PaginationConfig?
    
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
