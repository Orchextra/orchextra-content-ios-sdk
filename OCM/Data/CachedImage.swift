//
//  CachedImage.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

// TODO: !!! Document
enum ImageCachePriority {
    case low
    case high
}

class CachedImage {
    
    /// `String` representation of the image's `URL`.
    let imagePath: String
    /// Caching priority
    var priority: ImageCachePriority
    /// Location in disk for cached image, if `nil` the image is in process of being cached.
    private(set) var location: URL?
    /// Collection of associated content to the cached image, evaluated for garbage collection.
    private(set) var associatedContent: [Content]
    /// Collection of completion handlers to fire when caching is completed.
    private(set) var completionHandlers: [ImageCacheCompletion]
    
    // MARK: - Initializer
    
    init(imagePath: String, location: URL?, priority: ImageCachePriority, associatedContent: Content?, completion: ImageCacheCompletion?) {
        self.imagePath = imagePath
        self.location = location
        self.priority = priority
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
    
    // MARK: - Public methods
    
    /// Document !!!
    func associate(with content: Content) {
        
        guard self.associatedContent.contains(where: { (associatedContent) -> Bool in
            return content.elementUrl == associatedContent.elementUrl
        }) else {
            self.associatedContent.append(content)
            return
        }
    }
    
    /// Document !!!
    func addCompletionHandler(completion: @escaping ImageCacheCompletion) {
        self.completionHandlers.append(completion)
    }
    
    /// Document !!!
    func cache(location: URL) {
        self.location = location
    }
    
    /// Document !!!
    func complete(image: UIImage?, error: ImageCacheError?) {
        
        for completion in self.completionHandlers {
            completion(image, error)
        }
        self.completionHandlers.removeAll()
    }
}

extension CachedImage: Hashable {
    
    var hashValue: Int {
        return imagePath.hashValue
    }
    
    static func == (lhs: CachedImage, rhs: CachedImage) -> Bool {
        return lhs.imagePath == rhs.imagePath
    }
}
