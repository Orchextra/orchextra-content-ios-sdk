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
    static var CountryCode = ""
    static var AppVersion = ""
	static var placeholder: UIImage?
	static var noContentImage: UIImage?
    
    class func LanguageCode() -> String {
        return Locale.currentLanguageCode()
    }
    
    class func AppHeaders() -> [String: String] {
        return [
            "X-app-version": self.AppVersion,
            "X-app-country": self.CountryCode,
            "X-app-language": self.LanguageCode()
        ]
    }
    
    static var Palette: Palette? {
        didSet {
            UINavigationBar.appearance().barTintColor = self.Palette?.navigationBarColor
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
            UIToolbar.appearance().backgroundColor = self.Palette?.navigationBarColor
            UIToolbar.appearance().tintColor = UIColor.white
        }
    }
    
}
