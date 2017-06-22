//
//  UIImageView+Extension.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 22/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

extension UIImageView {

    func pathAdaptedToSize(path: String) -> String {
        
        let scale = Int(UIScreen.main.scale)
        let width = Int(self.width())
        let height = Int(self.height())
        
        let sizedUrl = UrlSizedComposserWrapper(
            urlString: path,
            width: width,
            height: height,
            scaleFactor: scale
        )
        
        return sizedUrl.urlCompossed
    }
    
    func imageAdaptedToSize(image: UIImage) -> UIImage? {
    
        let scale = Int(UIScreen.main.scale)
        let width = Int(self.width())
        let height = Int(self.height())
        
        let size = CGSize(width: width * scale, height: height * scale)
        let resizedImage = image.imageProportionally(with: size)
        
        return resizedImage
    }
    
}
