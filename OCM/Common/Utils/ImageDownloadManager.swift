//
//  ImageDownloadManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 22/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

/// Image download on completion receives the expected image or an error
typealias ImageDownloadCompletion = (UIImage?, ImageCacheError?) -> Void

class ImageDownloadManager {
    
    // MARK: Singleton
    static let shared = ImageDownloadManager()
    
    // MARK: Private properties
    /// Concurrent queues
    private let cacheQueue = DispatchQueue(label: "com.woah.imageDownloadManager.cacheQueue", attributes: .concurrent)
    private let downloadQueue = DispatchQueue(label: "com.woah.imageDownloadManager.downloadQueue", attributes: .concurrent)
    /// Downloads
    private var downloadPool: [String: DispatchWorkItem] = [:]
    private var downloadStack: [(String, DispatchWorkItem)] = []
    /// Images in memory
    private let imagesInMemoryLimit: Int = 36
    private var cachedImagesInMemory: [(String, UIImage)] = []
    private var onDemandImagesInMemory: [(String, UIImage)] = []
    /// Memory warning notification
    private var notification: NSObjectProtocol?

    // MARK: - Object life cycle
    
    init() {
        self.notification = NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { _ in
            self.onDemandImagesInMemory.removeAll()
            self.downloadStack.removeAll()
        }
    }
    
    deinit {
        if let notification = self.notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }

    // MARK: - Public methods
    
    /**
     Downloads an image with the provided path and sets it up on an `UIImageView`.
     If `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter imageView: An `UIImageView` wehre the image will be set.
     - parameter placeholder: A placeholder image to use as the image is being downloaded or retrieved from OCM's cache. **Important**: Always set this placeholder when loading images in reusable cells, otherwise, the behaviour of
     what's on display will be faulty as you scroll on your Collection View or Table View.
     */
     func downloadImage(with imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        
        guard Config.offlineSupportConfig != nil else {
            // If there's no offline support, use UIImageView extension for downloading the image
            imageView.imageFromURL(urlString: imageView.pathAdaptedToSize(path: imagePath), placeholder: placeholder)
            return
        }
        
        imageView.image = placeholder
        if let image = self.imageFromMemory(imagePath: imagePath) {
            self.displayImage(image, with: imagePath, in: imageView)
        } else {
            if ContentCacheManager.shared.shouldCacheImage(with: imagePath) {
                if ContentCacheManager.shared.isImageCached(imagePath) {
                    // If it's cached, retrieve and display
                    logInfo("ImageDownloadManager - Image is cached, will retrieve and display. Image with path: \(imagePath)")
                    self.retrieveImageFromCache(imagePath: imagePath, in: imageView, placeholder: placeholder)
                } else {
                    // If it's not cached, download the image and save on cache
                    logInfo("ImageDownloadManager - Image is not cached but it's supposed to be cached, will download image and save in cache. Image with path: \(imagePath)")
                    self.downloadImage(imagePath: imagePath, in: imageView, placeholder: placeholder, caching: true)
                }
            } else {
                logInfo("ImageDownloadManager - The content is not supposed to be cached, will download image. Image with path: \(imagePath)")
                self.downloadImage(imagePath: imagePath, in: imageView, placeholder: placeholder, caching: false)
            }
        }
    }
    
    /**
     Downloads an image with the provided path and fires the provided completion handler with the result.
     If the `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter completion: Completion handler to fire when download is completed, receiving the expected image
     or an error.
     */
    func downloadImage(with imagePath: String, completion: @escaping ImageDownloadCompletion) {
        
        guard Config.offlineSupportConfig != nil, ContentCacheManager.shared.shouldCacheImage(with: imagePath) else {
            // If there's no offline support or the content is not cached, download the image
            logInfo("ImageDownloadManager - There's no offline support or the content is not supposed to be cached, will download image the usual way. Image with path: \(imagePath)")
            self.downloadImageWithoutCache(imagePath: imagePath, completion: completion)
            return
        }
        
        if let image = self.imageFromMemory(imagePath: imagePath) {
            completion(image, .none)
        } else {
            if ContentCacheManager.shared.isImageCached(imagePath) {
                logInfo("ImageDownloadManager - Image is cached, will retrieve and display. Image with path: \(imagePath)")
                // If it's cached, retrieve and display
                self.retrieveImageFromCache(imagePath: imagePath, completion: completion)
            } else {
                logInfo("ImageDownloadManager - Image is not cached but it's supposed to be cached, will download image and save in cache. Image with path: \(imagePath)")
                // If it's not cached, download the image and save on cache
                self.downloadImageAndCache(imagePath: imagePath, completion: completion)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func downloadImage(imagePath: String, in imageView: URLImageView, placeholder: UIImage?, caching: Bool) {
        
        let size = imageView.size()
        let scale = UIScreen.main.scale
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                // Save in cache
                if caching {
                    ContentCacheManager.shared.cacheImage(image, imageData: data, with: imagePath)
                }
                let resizedImage = imageView.imageAdaptedToSize(image: image, size: size, scale: scale)
                strongSelf.displayImage(resizedImage, with: imagePath, in: imageView)
                strongSelf.saveOnDemandImageInMemory(resizedImage, with: imagePath)
                strongSelf.finishDownload(imagePath: imagePath)
            } else {
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func retrieveImageFromCache(imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {

        let size = imageView.size()
        let scale = UIScreen.main.scale
        self.cacheQueue.async {
            ContentCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                guard let image = image else { logWarn("image is nil"); return }
                let resizedImage = imageView.imageAdaptedToSize(image: image, size: size, scale: scale)
                self.displayImage(resizedImage, with: imagePath, in: imageView)
                self.saveCachedImageInMemory(resizedImage, with: imagePath)
            })
        }
    }
    
    private func downloadImageWithoutCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { logWarn("self is nil"); return }
            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        strongSelf.saveOnDemandImageInMemory(image, with: imagePath)
                        completion(image, .none)
                    } else {
                        completion(.none, .downloadFailed)
                    }
                    strongSelf.finishDownload(imagePath: imagePath)
                }
            } else {
                completion(.none, .invalidUrl)
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func downloadImageAndCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { logWarn("self is nil"); return }
            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url) {
                // Save in cache
                let image = UIImage(data: data)
                if let unwrappedImage = image {
                    ContentCacheManager.shared.cacheImage(unwrappedImage, imageData: data, with: imagePath)
                }
                DispatchQueue.main.async {
                    if let unwrappedImage = image {
                        strongSelf.saveCachedImageInMemory(unwrappedImage, with: imagePath)
                        completion(unwrappedImage, .none)
                    } else {
                        completion(.none, .downloadFailed)
                    }
                    strongSelf.finishDownload(imagePath: imagePath)
                }
            } else {
                completion(.none, .invalidUrl)
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func retrieveImageFromCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        // Retrieve image from cache
        self.cacheQueue.async {
            ContentCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                DispatchQueue.main.async {
                    if let image = image {
                        self.saveCachedImageInMemory(image, with: imagePath)
                        completion(image, .none)
                    } else {
                        completion(.none, .notCached)
                    }
                }
            })
        }
    }
    
    private func displayImage(_ image: UIImage?, with imagePath: String, in imageView: URLImageView) {
        
        DispatchQueue.main.async {
            if imageView.url == imagePath {
                UIView.transition(
                    with: imageView,
                    duration: 0.4,
                    options: .transitionCrossDissolve,
                    animations: {
                        imageView.clipsToBounds = true
                        imageView.contentMode = .scaleAspectFill
                        imageView.image = image
                },
                    completion: nil)
            }
        }
    }
    
    // MARK: - Download stack helpers
    
    private func pushForDownload(imagePath: String, dispatchWorkItem: DispatchWorkItem) {
        
        if let downloadItem = self.downloadPool[imagePath] {
            downloadItem.cancel()
            self.downloadPool.removeValue(forKey: imagePath)
        }
        self.downloadStack.append((imagePath, dispatchWorkItem))
        self.popForDownload()
    }
    
    private func popForDownload() {
        
        if downloadPool.count <= 3, let stackedDownload = self.downloadStack.popLast() {
            self.downloadPool[stackedDownload.0] = stackedDownload.1
            self.downloadQueue.async(execute: stackedDownload.1)
        }
    }
    
    private func finishDownload(imagePath: String) {
        
        DispatchQueue.main.async {
            self.downloadPool.removeValue(forKey: imagePath)
            self.popForDownload()
        }
    }
    
    // MARK: Images in memory helpers
    
    private func imageFromMemory(imagePath: String) -> UIImage? {
        
        var result: UIImage?
        if let imageInMemory = self.cachedImagesInMemory.first(where: { $0.0 == imagePath }) {
            result = imageInMemory.1
        } else if let imageInMemory = self.onDemandImagesInMemory.first(where: { $0.0 == imagePath }) {
            result = imageInMemory.1
        }
        return result
    }
    
    private func saveCachedImageInMemory(_ image: UIImage?, with imagePath: String) {
        
        guard let image = image else { logWarn("image is nil"); return }
        DispatchQueue.main.async {
            if self.cachedImagesInMemory.count > self.imagesInMemoryLimit {
                self.cachedImagesInMemory.removeFirst()
            }
            self.cachedImagesInMemory.append((imagePath, image))
        }
    }
    
    private func saveOnDemandImageInMemory(_ image: UIImage?, with imagePath: String) {
        
        guard let image = image else { logWarn("image is nil"); return }
        DispatchQueue.main.async {
            if self.onDemandImagesInMemory.count > self.imagesInMemoryLimit {
                self.onDemandImagesInMemory.removeFirst()
            }
            self.onDemandImagesInMemory.append((imagePath, image))
        }
    }
    
    // MARK: Handy helpers
    
    private func urlAdaptedToSize(_ urlString: String) -> String {
        if let url = URLComponents(string: urlString),
            let originalwidth = url.queryItems?.first(where: { $0.name == "originalwidth" })?.value,
            let width = Double(originalwidth),
            (CGFloat(width) / UIScreen.main.scale) < UIScreen.main.bounds.width {
            return urlString
        }
        return UrlSizedComposserWrapper(urlString: urlString, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
    }

}
