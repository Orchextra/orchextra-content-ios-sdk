//
//  Config.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

/// UI controls for navigating throught the content
public enum NavigationType {
    /// Buttons.
    case button
    /// Navigation bar.
    case navigationBar
}

class Config {
    
    static var Host = ""
    static var AppVersion = ""
    
	static var placeholder: UIImage?
    static var thumbnailEnabled: Bool = true
    
    static var contentListMarginsColor: UIColor? = .white
    static var contentListBackgroundColor: UIColor? = .groupTableViewBackground
    
    static var loadingView: StatusView?
    static var noContentView: StatusView?
    static var noSearchResultView: StatusView?
    static var blockedContentView: StatusView?
    
    static var navigationType: NavigationType = .button
    static var primaryColor: UIColor = .blue
    static var secondaryColor: UIColor = .white
    static var navigationBarBackgroundImage: UIImage?
    static var navigationButtonBackgroundImage: UIImage?
    static var navigationTransitionBackgroundImage: UIImage?
    static var errorView: ErrorView.Type?
    static var isLogged: Bool = false
    
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
