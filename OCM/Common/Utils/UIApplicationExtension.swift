//
//  UIWindowExtension.swift
//  OCM
//
//  Created by José Estela on 7/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    func takeScreenshot() -> UIImage? {
        guard let layer = self.keyWindow?.layer else {
            logWarn("Key window cannot get")
            return nil
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
