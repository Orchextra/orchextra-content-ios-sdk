//
//  CachedImage.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

class CachedImage {
    
    let imagePath: String
    let location: URL
    //var associatedContent: [Any] // For garbage collection !!! ???
    
    init(imagePath: String, location: URL) {
        self.imagePath = imagePath
        self.location = location
        //self.associatedContent = [associatedContent]
    }
}
