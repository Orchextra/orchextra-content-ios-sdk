//
//  CachedImage.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

/**
 Caching priority for image.
 
 - high: for images that have priority on the download queue, i.e.: download will start ASAP, if there's a 
 low priority download in progress, it will be paused for downlading the high priority one.
 - low: for images that need to be cached but have no priority on the download queue, i.e.: it will download 
 only there are no high priority images pending for download.
 */
enum ImageCachePriority {
    case high
    case low
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
    
    /**
     Associate image cache to content. Evaluated for garbage collection.
     
     - parameter content: `Content` that references the cached image.
     */
    func associate(with content: Content) {
        
        guard self.associatedContent.contains(where: { (associatedContent) -> Bool in
            return content.elementUrl == associatedContent.elementUrl
        }) else {
            self.associatedContent.append(content)
            return
        }
    }
    
    /**
     Add completion handler for caller requesting cached image.
     
     - parameter completion: Closure that will be executed once the image caching finishes, recieving the expected
     image or an error.
     */
    func addCompletionHandler(completion: @escaping ImageCacheCompletion) {
        self.completionHandlers.append(completion)
    }
    
    /**
     Set disk location for cached image.
     
     - parameter location: `URL` for file storing data for cached image.
     */
    func cache(location: URL) {
        self.location = location
    }
    
    /**
     Executes all completion closures for cached image with the expected image or error.
     
     - parameter image: expected image if cached succesfully.
     - parameter error: `ImageCacheError` if there was an issue while caching the image.
     */
    func complete(image: UIImage?, error: ImageCacheError?) {
        
        for completion in self.completionHandlers {
            completion(image, error)
        }
        self.completionHandlers.removeAll()
    }
}

// MARK: - Hashable

extension CachedImage: Hashable {
    
    var hashValue: Int {
        return imagePath.hashValue
    }
    
    static func == (lhs: CachedImage, rhs: CachedImage) -> Bool {
        return lhs.imagePath == rhs.imagePath
    }
}
