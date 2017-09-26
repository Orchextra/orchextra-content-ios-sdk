//
//  ImageCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 07/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

// Ignore file line length rule as comments are not ignored and this is throughly commented class
// swiftlint:disable file_length

/// Error for image caching
enum ImageCacheError: Error {
    
    case invalidUrl
    case retryLimitExceeded
    case downloadFailed
    case cachingFailed
    case cachingCancelled
    case notCached
    case unknown
    
    func description() -> String {
        switch self {
        case .invalidUrl:
            return "The provided URL is invalid, unable to download expected image"
        case .retryLimitExceeded:
            return "Unable to download expected image after 3 attempts"
        case .downloadFailed:
            return "Unable to download expected image"
        case .cachingCancelled:
            return "Caching process aborted, unable to cache the expected image"
        case .cachingFailed:
            return "Unable to cache on disk the expected image"
        case .notCached:
            return "The expected image is not cached"
        case .unknown:
            return "Unable to cache image, unknown error"
        }
    }
}

/// Image caching on completion receives the expected image or an error
typealias ImageCacheCompletion = (UIImage?, ImageCacheError?) -> Void

/**
 Handles image caching, responsible for:
 
 - Obtaining images from cache (persistent store).
 - Downloading images from a remote server (using priority queues for firing background downloads).
 - Handles events for downloads, i.e.: success and error cases.
 - Pause all active image downloads.
 - Resume all paused image downloads.
 - Cancel all image downloads.
 
 */
class ImageCacheManager {
    
    /// Singleton
    static let shared = ImageCacheManager()

    // MARK: Private properties
    private var cachedImages = Set<CachedImage>()
    private var backgroundDownloadManager = BackgroundDownloadManager()
    private var imagePersister: ImagePersister
    private var downloadPaused: Bool = false
    private let downloadLimit: Int = 2
    private var downloadsInProgress = Set<CachedImage>()
    
    private let lowPriorityQueue = DispatchQueue(label: "com.woah.imageCacheManager.lowPriorityQueue", attributes: .concurrent)
    private var _lowPriorityDownloads: [CachedImage] = []
    private var lowPriorityDownloads: [CachedImage] {
        var copy: [CachedImage]?
        self.lowPriorityQueue.sync {
            copy = self._lowPriorityDownloads
        }
        return copy ?? [CachedImage]()
    }
    
    private let highPriorityQueue = DispatchQueue(label: "com.woah.imageCacheManager.highPriorityQueue", attributes: .concurrent)
    private var _highPriorityDownloads = [CachedImage]()
    private var highPriorityDownloads: [CachedImage] {
        var copy: [CachedImage]?
        self.highPriorityQueue.sync {
            copy = self._highPriorityDownloads
        }
        return copy ?? [CachedImage]()
    }
    
    // MARK: - Initializers
    
    private init() {
        self.backgroundDownloadManager.configure(backgroundSessionCompletionHandler: Config.backgroundSessionCompletionHandler)
        self.imagePersister = ImageCoreDataPersister.shared
        self.loadCachedImages()
    }
    
    // MARK: - Private setup methods
    
    private func loadCachedImages() {
        self.cachedImages = Set(self.imagePersister.loadCachedImages())
    }
    
    // MARK: - Public methods

    /**
     Caches an image, retrieving it from disk if already cached or downloading if not.
     
     - parameter imagePath: `String` representation of the image's `URL`.
     - parameter dependency: `String` identifier for the element that references the cached image.
     - parameter priority: Caching priority,`.high` only for those that will be shown on display.
     - parameter completion: Completion handler to fire when caching is completed, receiving the expected image
     or an error.
     */
    func cacheImage(for imagePath: String, withDependency dependency: String, priority: ImageCachePriority, completion: ImageCacheCompletion?) {
        
        // Check if it exists already, if not: download
        guard let cachedImage = self.cachedImage(with: imagePath) else {
            let cachedImage = CachedImage(imagePath: imagePath, filename: .none, priority: priority, status: .caching, dependency: dependency, completion: completion)
            self.enqueueForDownload(cachedImage)
            return
        }
        
        if let filename = cachedImage.filename {
            if let image = self.image(for: filename) {
                // If it exists, add dependency and return image
                cachedImage.associate(with: dependency)
                cachedImage.addCompletionHandler(completion: completion)
                self.imagePersister.save(cachedImage: cachedImage)
                cachedImage.complete(image: image, error: .none)
                logInfo("ImageCacheManager - Image is in cache already. Path for image: \(imagePath)")
            } else {
                // If it exists but can't be loaded, return error
                cachedImage.complete(image: .none, error: .unknown)
            }
        } else {
            // If it's being downloaded, add dependency and add it's completion handler
            cachedImage.associate(with: dependency)
            if let completionHandler = completion {
                cachedImage.addCompletionHandler(completion: completionHandler)
            }
            logInfo("ImageCacheManager - Image is currently being downloaded. Path for image: \(imagePath)")
        }
    }
    
    /**
     Looks for an image in the cache, retrieving it from disk if it's cached.
     
     - parameter imagePath: `String` representation of the image's `URL`.
     - parameter completion: Completion handler to fire when looking for the image in cache is completed, receiving the 
     expected image or an error.
     */
    func cachedImage(with imagePath: String, completion: @escaping ImageCacheCompletion, priority: ImageCachePriority) {
        
        guard Config.offlineSupport, let cachedImage = self.cachedImage(with: imagePath) else {
            return
        }
        
        if let filename = cachedImage.filename, let image = self.image(for: filename) {
            // It's cached
            logInfo("ImageCacheManager - Image is in cache already. Path for image: \(imagePath)")
            completion(image, .none)
        } else {
            // It's being cached
            logInfo("ImageCacheManager - Image is currently being downloaded. Path for image: \(imagePath)")
            switch priority {
            case .low:
                cachedImage.addCompletionHandler(completion: completion)
            case .high:
                completion(.none, .unknown)
            }
        }
    }

    /**
     Pauses the image caching process.
     All image downloads are paused, except those with a high a priority that were already in progress.
     */
    func pauseCaching() {
        self.downloadPaused = true
        for download in self.downloadsInProgress where download.priority == .low {
            // Only pause active downloads that have a low priority
            let downloadPath = self.urlAdaptedToSize(download.imagePath)
            self.backgroundDownloadManager.pauseDownload(downloadPath: downloadPath)
        }
    }
    
    /**
     Resumes the image caching process.
     All image downloads that were paused are resumed in the expected order.
     */
    func resumeCaching() {
        self.downloadPaused = false
        if self.downloadsInProgress.count > 0 {
            // Resume paused downloads if any
            self.backgroundDownloadManager.resumeDownloads()
        } else {
            // If no downloads are paused, dequeue those that are pending for download
            self.dequeueForDownload()
        }
    }
    
    /**
     Cancels the image caching process.
     Completion handlers for images being cached are fired with a cancellation error.
     */
    func cancelCaching() {
        self.downloadPaused = true
        self.backgroundDownloadManager.cancelDownloads()
        let downloads  = self.lowPriorityDownloads + self.highPriorityDownloads + self.downloadsInProgress
        for download in downloads {
            download.complete(image: .none, error: .cachingCancelled)
        }
        self.lowPriorityQueue.async (flags: .barrier) {
            self._lowPriorityDownloads.removeAll()
        }
        self.highPriorityQueue.async (flags: .barrier) {
            self._highPriorityDownloads.removeAll()
        }
        self.downloadsInProgress.removeAll()
        self.downloadPaused = false
    }
    
    /**
     Cleans the image cache, removing from disk and from the persistent store all
     references to images that are not currently referenced.
     
     - parameter currentImages: An array with the paths for the images that are currently referenced.
     */
    func cleanCache(currentImages: [String]) {
        // TODO: Perform garbage collection
        // Implement using Set's difference operator between the elements in `currentImages` and what's stored on imagePersister !!!
        // self.imagePersister.removeCachedImages(with: "test") // Send the difference
    }

    /**
     Deletes all images being cached, removing from disk and from the persistent store.
     */
    func resetCache() {
        // Remove from persistent store
        self.imagePersister.removeCachedImages()
        // Delete from disk
        for cachedImage in self.cachedImages {
            if let filename = cachedImage.filename, let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                try? FileManager.default.removeItem(at: documentsUrl.appendingPathComponent(filename))
            }
        }
    }
    
    /**
     Determines whether an image for a given path is currently cached or not.
     
     - parameter imagePath: `String` representation for the path of the image to evaluate.
     - returns: `ImageCacheStatus` with the caching status for the image.
     */
    func isImageCached(_ imagePath: String) -> ImageCacheStatus {
    
        if let cachedImage = self.cachedImage(with: imagePath) {
            return cachedImage.status
        }
        return .none
    }
    
    /**
     Saves an image on the cache.
     
     - parameter image: Image to save in cache.
     - parameter imageData: Data representation of the image.
     - parameter imagePath: `String` representation of the image's `URL`.
     - parameter dependency: `String` identifier for the element that references the cached image.
     */
    func cacheImage(image: UIImage, imageData: Data, with imagePath: String, dependendency: String) {
        
        let filename = "download-\(imagePath.hashValue)"
        if let fileUrl = self.locationForImage(with: filename) {
            let cachedImage = CachedImage(imagePath: imagePath, filename: filename, dependencies: [dependendency])
            try? imageData.write(to: fileUrl)
            self.cachedImages.update(with: cachedImage)
            self.imagePersister.save(cachedImage: cachedImage)
        }
    }
    
    // MARK: - Private methods
    
    // MARK: Download helpers
    
    private func downloadImageForCaching(cachedImage: CachedImage) {
        
        logInfo("ImageCacheManager - Will download image. Path for image: \(cachedImage.imagePath). Priority: \(cachedImage.priority.rawValue)")
        
        let downloadPath = self.urlAdaptedToSize(cachedImage.imagePath)
        self.backgroundDownloadManager.startDownload(downloadPath: downloadPath, completion: { (filename, error) in
            
            if error == .none, let filename = filename, let image = self.image(for: filename) {
                self.downloadsInProgress.remove(cachedImage)
                cachedImage.cache(filename: filename)
                cachedImage.complete(image: image, error: .none)
                self.cachedImages.update(with: cachedImage)
                self.imagePersister.save(cachedImage: cachedImage)
                if !self.downloadPaused { self.dequeueForDownload() }
            } else {
                self.downloadsInProgress.remove(cachedImage)
                cachedImage.complete(image: .none, error: self.translateError(error: error))
            }
        })
    }
    
    // MARK: Download queues helpers 
    
    private func enqueueForDownload(_ cachedImage: CachedImage) {
    
        switch cachedImage.priority {
        case .low:
            self.enqueueLowPriorityDownload(cachedImage)
            break
        case .high:
            self.enqueueHighPriorityDownload(cachedImage)
            break
        }
    }
    
    private func dequeueForDownload() {
        guard self.dequeueHighPriorityDownload() else {
            _ = self.dequeueLowPriorityDownload()
            return
        }
    }
    
    private func enqueueLowPriorityDownload(_ cachedImage: CachedImage) {
        if self.downloadsInProgress.count < self.downloadLimit {
            // Download if there's place on the download queue
            self.downloadsInProgress.insert(cachedImage)
            self.downloadImageForCaching(cachedImage: cachedImage)
        } else {
            // Add to low priority download queue
            self.lowPriorityQueue.async (flags: .barrier) {
                self._lowPriorityDownloads.append(cachedImage)
            }
        }
    }
    
    private func dequeueLowPriorityDownload() -> Bool {
        if let download = self.lowPriorityDownloads.first {
            self.lowPriorityQueue.async (flags: .barrier) {
                self._lowPriorityDownloads.remove(at: 0)
            }
            self.enqueueForDownload(download)
            return true
        }
        return false
    }
    
    private func enqueueHighPriorityDownload(_ cachedImage: CachedImage) {
        
        if let lowPriorityDownload = self.lowPriorityDownloadInProgress() {
            // Pause low priority download (if any) and move to the low priority queue
            let downloadPath = self.urlAdaptedToSize(lowPriorityDownload.imagePath)
            self.backgroundDownloadManager.pauseDownload(downloadPath: downloadPath)
            self.downloadsInProgress.remove(lowPriorityDownload)
            self.lowPriorityQueue.async (flags: .barrier) {
                self._lowPriorityDownloads.append(lowPriorityDownload)
            }
            // Start high priority download
            self.downloadsInProgress.insert(cachedImage)
            self.downloadImageForCaching(cachedImage: cachedImage)
        } else {
            if self.downloadsInProgress.count < self.downloadLimit {
                // Download if there's place on the download queue
                self.downloadsInProgress.insert(cachedImage)
                self.downloadImageForCaching(cachedImage: cachedImage)
            } else {
                // Add to high priority download queue
                self.highPriorityQueue.async (flags: .barrier) {
                    self._highPriorityDownloads.append(cachedImage)
                }
            }
        }
    }
    
    private func dequeueHighPriorityDownload() -> Bool {
        if let download = self.highPriorityDownloads.first {
            self.highPriorityQueue.async (flags: .barrier) {
                self._highPriorityDownloads.remove(at: 0)
            }
            self.enqueueForDownload(download)
            return true
        }
        return false
    }
    
    // MARK: Handy helpers
    
    private func lowPriorityDownloadInProgress() -> CachedImage? {
        
        let downloadInProgress = self.downloadsInProgress.first { (download) -> Bool in
            download.priority == .low
        }
        return downloadInProgress
    }
    
    private func cachedImage(with imagePath: String) -> CachedImage? {
        
        return self.cachedImages.first(where: { (cachedImage) -> Bool in
            return cachedImage.imagePath == imagePath
        })
    }
    
    private func image(for filename: String) -> UIImage? {
        
        guard
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
        let data = try? Data(contentsOf: documentsUrl.appendingPathComponent(filename))
        else { return nil }
       
        return UIImage(data: data)
    }
    
    private func locationForImage(with filename: String) -> URL? {
        
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsUrl.appendingPathComponent(filename)
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
    
    private func urlAdaptedToSize(_ urlString: String) -> String {
        return UrlSizedComposserWrapper(urlString: urlString, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
    }
    
}
