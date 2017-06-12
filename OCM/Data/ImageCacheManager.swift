//
//  ImageCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 07/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public enum ImageCacheError: Error {
    
    case invalidUrl
    case retryLimitExceeded
    case downloadFailed
    case cachingFailed
    case unknown
    
    func description() -> String {
        switch self {
        case .invalidUrl:
            return "The provided URL is invalid, unable to download expected image"
        case .retryLimitExceeded:
            return "Unable to download expected image after 3 attempts"
        case .downloadFailed:
            return "Unable to download expected image"
        case .cachingFailed:
            return "Unable to cache on disk the expected image"
        case .unknown:
            return "Unable to cache image, unknown error"
        }
    }
}

public typealias ImageCacheCompletion = (UIImage?, ImageCacheError?) -> Void

/// TODO: Document properly !!! Manager for caching images
public class ImageCacheManager {
    
    // MARK: Singleton
    public static let shared = ImageCacheManager()
    
    // MARK: Private properties
    fileprivate var cachedImages: [CachedImage]
    fileprivate var backgroundDownloadManager: BackgroundDownloadManager
    
    // MARK: - Initializers
    
    init() {
        self.cachedImages = []
        self.backgroundDownloadManager = BackgroundDownloadManager.shared
        self.backgroundDownloadManager.configure(backgroundSessionCompletionHandler: Config.backgroundSessionCompletionHandler)
    }
    
    // MARK: - Public methods
    
    public func cachedImage(for imagePath: String, with associatedContent: Content, completion: @escaping ImageCacheCompletion) {
        
        // Check if it exists already
        guard let cachedImage = self.cachedImage(with: imagePath) else {
            // If it doesn't exist, then download
            let cachedImage = CachedImage(imagePath: imagePath, location: .none, associatedContent: associatedContent, completion: completion)
            self.downloadImageForCaching(cachedImage: cachedImage)
            return
        }
        
        if let location = cachedImage.location {
            if let image = self.image(for: location) {
                // If it exists, associate content and return image
                cachedImage.associate(with: associatedContent)
                cachedImage.complete(image: image, error: .none)
            } else {
                // If it exists but can't be loaded, return error
                cachedImage.complete(image: .none, error: .unknown)
            }
        } else {
            // If it's being downloaded, associate content and add it's completion handler
            cachedImage.associate(with: associatedContent)
            cachedImage.addCompletionHandler(completion: completion)
        }
        
    }
    
    // MARK: - Download methods

    public func startCaching(images: [String : String]) {
    
        // TODO: !!!
        for _ in images {
            //self.backgroundDownloadManager.startDownload(downloadPath: element.value)
        }
    }
    
    // TODO: Document
    func pauseCaching() {
        
    }
    
    // TODO: Document
    func cancelCaching() {
        
    }
    
    // TODO: Document
    func resumeCaching() {
        
    }
    
    // MARK: - Private helpers
    
    private func downloadImageForCaching(cachedImage: CachedImage) {
        
        self.addCachedImage(cachedImage)
        self.backgroundDownloadManager.startDownload(downloadPath: cachedImage.imagePath, completion: { (location, error) in
            
            if error == .none, let location = location, let image = self.image(for: location) {
                cachedImage.cache(location: location)
                cachedImage.complete(image: image, error: .none)
            } else {
                self.removeCachedImage(cachedImage)
                cachedImage.complete(image: .none, error: self.translateError(error: error))
            }
        })
    }
    
    private func cachedImage(with imagePath: String) -> CachedImage? {
        
        let filteredCache = self.cachedImages.filter { (cachedImage) -> Bool in
            return cachedImage.imagePath == imagePath && cachedImage.location != .none
        }
        
        return filteredCache.first
    }
    
    private func image(for location: URL) -> UIImage? {
        
        guard let data = try? Data(contentsOf: location) else { return .none }
        return UIImage(data: data)
    }
    
    private func addCachedImage(_ cachedImage: CachedImage) {
        self.cachedImages.append(cachedImage)
    }
    
    private func removeCachedImage(_ cachedImage: CachedImage) {
        self.cachedImages = self.cachedImages.filter({ (image) -> Bool in
            image.imagePath != cachedImage.imagePath
        })
    }
    
    private func translateError(error: BackgroundDownloadError?) -> ImageCacheError {
        
        guard let error = error else {
            return .cachingFailed
        }
        switch error {
        case .invalidUrl:
            return .invalidUrl
        case .retryLimitExceeded:
            return .retryLimitExceeded
        case .unknown:
            return .downloadFailed
        }
    }

    func clean() {
        
        // TODO: !!!
        // Perform garbage collection
    }


}
