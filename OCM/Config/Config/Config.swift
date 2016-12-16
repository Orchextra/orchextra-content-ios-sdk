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
    
	static var placeholder: UIImage?
    
    static var contentListMarginsColor: UIColor? = .white
    static var contentListBackgroundColor: UIColor? = .groupTableViewBackground
    
    static var loadingView: StatusView?
    static var noContentView: StatusView?
    static var noSearchResultView: StatusView?
    static var blockedContentView: StatusView?

    static var errorView: ErrorView.Type?
    static var isLogged: Bool = false
    
    class func LanguageCode() -> String {
        return Locale.currentLanguageCode()
    }
    
    static var Palette: Palette?
	
	static var SDKVersion: String {
		let bundle = Bundle.OCMBundle()
        let sdkVersion: String? = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        let versionNumber = sdkVersion ?? "1.0.1" // To avoid problems in production
		let version = "IOS_\(versionNumber)"
		return version
	}
}
