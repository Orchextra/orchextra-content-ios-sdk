//
//  Font+Load.swift
//  OCM
//
//  Created by Alejandro Jiménez on 16/1/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

extension UIFont {

	internal static func loadSDKFont(fromFile fileString: String) {

        _ = self.familyNames

		let bundle = Bundle.OCMBundle()
		guard let pathForResourceString = bundle.path(forResource: fileString, ofType: nil) else {
			return LogWarn("UIFont+:  Failed to register font (\(fileString)) - path for resource not found .")
		}

		guard let fontData = try? Data(contentsOf: URL(fileURLWithPath: pathForResourceString)) else {
			return LogWarn("UIFont+:  Failed to register font (\(fileString)) - font data could not be loaded.")
		}

		guard let dataProvider = CGDataProvider(data: fontData as CFData) else {
			return LogWarn("UIFont+:  Failed to register font (\(fileString)) - data provider could not be loaded.")
		}

		let fontRef = CGFont(dataProvider)

		var errorRef: Unmanaged<CFError>? = nil
		if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
			LogWarn("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
		}
	}

}
