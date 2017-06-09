//
//  ImageCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 07/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public enum ImageCacheError: Error {
    
    case invalidURL
    case retryLimitExceeded
    case cachingFailed
    case unknown
    
    func description() -> String {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid, unable to download expected image"
        case .retryLimitExceeded:
            return "Unable to download expected image after 3 attempts"
        case .cachingFailed:
            return "Unable to cache on disk the expected image"
        case .unknown:
            return "Unable to cache image, unknown error"
        }
    }
}

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
        self.backgroundDownloadManager = BackgroundDownloadManager()
        self.backgroundDownloadManager.configure(delegate: self, completionHandler: Config.backgroundSessionCompletionHandler)
    }
    
    // MARK: - Public methods
    
    public func cachedImage(for imagePath: String) {
    
        // TODO: !!!
        // If no disk, return image
        // else download image and cache
    }
    
    // MARK: - Download methods

    public func startCaching(images: [String : String]) {
    
        // TODO: !!!
        for element in images {
            self.backgroundDownloadManager.startDownload(downloadPath: element.value)
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
    
    func clean() {
        
        // TODO: !!!
        // Perform garbage collection
    }

    // MARK: Download helper methods
    
    func documentsPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    func localFilePathForImage(imagePath: String) -> URL? {
        if let documentsPath = self.documentsPath() {
            let url = URL(fileURLWithPath: documentsPath + imagePath)
            return url
        }
        return nil
    }

}

// MARK: - BackgroundDownloadDelegate

extension ImageCacheManager: BackgroundDownloadDelegate {
    
    func downloadSucceeded(downloadPath: String, data: Data, location: URL) {
        
        guard let destinationURL = localFilePathForImage(imagePath: downloadPath) else {
            return
        }
        
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            let cachedImage = CachedImage(imagePath: downloadPath, location: destinationURL)
            self.cachedImages.append(cachedImage)
        } catch {
           //!!!
        }
    }
    
    func downloadFailed(error: BakgroundDownloadError) {
        // TODO: Handle this
    }

}
