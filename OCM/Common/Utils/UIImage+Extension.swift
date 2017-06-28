//
//  UIImage+Extension.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 28/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

extension UIImage {
    
    func blurImage() -> UIImage {
        
        if let initialCGImage = self.cgImage {
            
            let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
            gaussianBlurFilter?.setValue(CIImage(cgImage: initialCGImage), forKey:kCIInputImageKey)
            let initialImage = CIImage(cgImage: initialCGImage)
            if let finalImage = gaussianBlurFilter?.outputImage {
                
                let finalImageContext = CIContext(options: nil)
                if let finalCGImage = finalImageContext.createCGImage(finalImage, from: initialImage.extent) {
                    
                    return UIImage(cgImage: finalCGImage)
                }
            }
        }
        return self
    }

}
