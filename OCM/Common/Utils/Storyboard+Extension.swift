//
//  Storyboard+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit


extension UIStoryboard {
	
	class func OCMStoryboard() -> UIStoryboard {
		return UIStoryboard(name: "OCM", bundle: Bundle.OCM())
	}
	
	
	class func ocmInitialVC() -> UIViewController? {
		let storyboard = UIStoryboard.OCMStoryboard()
		guard let initialVC = storyboard.instantiateInitialViewController() else {
			LogWarn("Couldn't found initial view controller")
			return nil
		}
		
		return initialVC
	}
    
    
    class func ocmViewController(_ name: String) -> UIViewController {
        let storyboard = UIStoryboard.OCMStoryboard()
        
        let viewController = storyboard.instantiateViewController(withIdentifier: name)
        
        return viewController
    }
	
}
