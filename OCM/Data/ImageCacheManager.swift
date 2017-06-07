//
//  ImageCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 07/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit


class CachedImage {
    
    let image: UIImage
    let path: String
    var associatedContent: [Any] // For garbage collection !!! ???
    
    init(image: UIImage, path: String, associatedContent: Any) {
        self.image = image
        self.path = path
        self.associatedContent = [associatedContent]
    }
}

/// TODO: Document properly !!! Manager for caching images
class ImageCacheManager {
    
    // MARK: Singleton
    static let shared = ImageCacheManager()

    // MARK: Private properties
    private var cachedImages: [CachedImage]
    
    // MARK: - Initializers
    
    init() {
        self.cachedImages = []
    }
    
    // MARK: - Public methods
    
    func cachedImage(for path: String) -> UIImage? {
        
        // Check stored images
        let cachedImage = self.cachedImages.first { (element) -> Bool in
            return element.path == path
        }
        
        if let image = cachedImage?.image {
            // Associate content and return cached image
            cachedImage?.associatedContent.append("myAssociatedContentPath") //FIXME: send reference to content as parameter
            return image
        } else {
            // TODO: Download, associate content, store and return
        }
        return nil
    }
    
    // MARK: - Private helpers
    
    func clean() {
    
        // TODO: !!!
        // Perform garbage collection
    }
}
