//
//  CachedImage.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class CachedImage {
    
    let imagePath: String
    var location: URL?
    var associatedContent: [Content] // For garbage collection !!! ???
    var completionHandlers: [ImageCacheCompletion]
    
    init(imagePath: String, location: URL?, associatedContent: Content?, completion: ImageCacheCompletion?) {
        self.imagePath = imagePath
        self.location = location
        if let associatedContent = associatedContent {
            self.associatedContent = [associatedContent]
        } else {
            self.associatedContent = []
        }
        if let completion = completion {
            self.completionHandlers = [completion]
        } else {
            self.completionHandlers = []
        }
    }
    
    func associate(with content: Content) {
        
        guard self.associatedContent.contains(where: { (associatedContent) -> Bool in
            return content.elementUrl == associatedContent.elementUrl
        }) else {
            self.associatedContent.append(content)
            return
        }
    }
    
    func addCompletionHandler(completion: @escaping ImageCacheCompletion) {
        self.completionHandlers.append(completion)
    }
    
    func cache(location: URL) {
        
        self.location = location
    }
    
    func complete(image: UIImage?, error: ImageCacheError?) {
        
        for completion in self.completionHandlers {
            completion(image, error)
        }
        self.completionHandlers.removeAll()
    }
}
