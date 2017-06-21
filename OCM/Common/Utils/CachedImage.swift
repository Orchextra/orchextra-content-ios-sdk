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
    /// Name for the file in disk with cached image, if `nil` the image is in process of being cached.
    private(set) var filename: String?
    /// Collection of dependencies to the cached image, evaluated for garbage collection.
    private(set) var dependencies: [String]
    /// Collection of completion handlers to fire when caching is completed.
    private(set) var completionHandlers: [ImageCacheCompletion]
    
    // MARK: - Initializer
    
    init(imagePath: String, filename: String?, priority: ImageCachePriority, dependency: String?, completion: ImageCacheCompletion?) {
        self.imagePath = imagePath
        self.filename = filename
        self.priority = priority
        if let dependency = dependency {
            self.dependencies = [dependency]
        } else {
            self.dependencies = []
        }
        if let completion = completion {
            self.completionHandlers = [completion]
        } else {
            self.completionHandlers = []
        }
    }
    
    init(imagePath: String, filename: String, dependencies: [String]) {
        self.imagePath = imagePath
        self.filename = filename
        self.dependencies = dependencies
        // Defaults
        self.priority = .low
        self.completionHandlers = []
    }
    
    // MARK: - Public methods
    
    /**
     Add a dependency to cached image. Evaluated for garbage collection.
     
     - parameter content: `String` identifier for the element that references the cached image.
     */
    func associate(with dependencyIdentifier: String) {
        
        guard self.dependencies.contains(where: { (dependency) -> Bool in
            return dependencyIdentifier == dependency
        }) else {
            self.dependencies.append(dependencyIdentifier)
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
     Set filename for file in disk with cached image.
     
     - parameter location: `URL` for file storing data for cached image.
     */
    func cache(filename: String) {
        self.filename = filename
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
