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
typealias ImageDownloadCompletion = (UIImage?, Bool, ImageCacheError?) -> Void

class ImageDownloadManager {
    
    // MARK: Single
    static let shared = ImageDownloadManager()
    
    /// Private properties
    private let downloadQueue = DispatchQueue(label: "com.woah.imageDownloadManager.downloadQueue", attributes: .concurrent)
    private var downloadPool: [String: DispatchWorkItem] = [:]
    private var downloadStack: [(String, DispatchWorkItem)] = []
    private let cacheQueue = DispatchQueue(label: "com.woah.imageDownloadManager.cacheQueue", attributes: .concurrent)
    
    private init() {}
    
    // MARK: - Public methods
    
    /**
     Downloads an image with the provided path and sets it up on an `UIImageView`.
     If the `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter imageView: An `UIImageView` wehre the image will be set.
     - parameter placeholder: A placeholder image to use as the image is being downloaded or retrieved from OCM's cache. **Important**: Always set this placeholder when loading images in reusable cells, otherwise, the behaviour of
     what's on display will be faulty as you scroll on your Collection View or Table View.
     */
     func downloadImage(with imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        
        guard Config.offlineSupport else {
            // If there's no offline support, use UIImageView extension for downloading the image
            imageView.imageFromURL(urlString: imageView.pathAdaptedToSize(path: imagePath), placeholder: placeholder)
            return
        }
        
        imageView.image = placeholder
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
            imageView.cached = false
            logInfo("ImageDownloadManager - The content is not supposed to be cached, will download image. Image with path: \(imagePath)")
            self.downloadImage(imagePath: imagePath, in: imageView, placeholder: placeholder, caching: false)
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
        
        guard Config.offlineSupport, ContentCacheManager.shared.shouldCacheImage(with: imagePath) else {
            // If there's no offline support or the content is not cached, download the image
            logInfo("ImageDownloadManager - There's no offline support or the content is not supposed to be cached, will download image the usual way. Image with path: \(imagePath)")
            self.downloadImageWithoutCache(imagePath: imagePath, completion: completion)
            return
        }
        
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
    
    // MARK: - Private helpers
    
    private func downloadImage(imagePath: String, in imageView: URLImageView, placeholder: UIImage?, caching: Bool) {
        
        // Download image
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    // Save in cache
                    if caching {
                    ContentCacheManager.shared.cacheImage(image, with: imagePath)
                    }
                    strongSelf.displayImage(image, with: imagePath, in: imageView, caching: caching)
                    strongSelf.finishDownload(imagePath: imagePath)
                } else {
                    strongSelf.finishDownload(imagePath: imagePath)
                }
            } else {
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func retrieveImageFromCache(imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        // Retrieve image from cache
        self.cacheQueue.async {
            ContentCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                guard let image = image else { return }
                self.displayImage(image, with: imagePath, in: imageView, caching: true)
            })
        }
    }
    
    private func displayImage(_ image: UIImage, with imagePath: String, in imageView: URLImageView, caching: Bool) {
        // Display image in URLImageView
        let resizedImage = imageView.imageAdaptedToSize(image: image)
        DispatchQueue.main.async {
            if imageView.url == imagePath {
                imageView.cached = caching
                UIView.transition(
                    with: imageView,
                    duration: 0.4,
                    options: .transitionCrossDissolve,
                    animations: {
                        imageView.clipsToBounds = true
                        imageView.contentMode = .scaleAspectFill
                        imageView.image = resizedImage
                },
                    completion: nil)
            }
        }
    }
    
    private func downloadImageWithoutCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            

            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.sync {
                    if let image = UIImage(data: data) {
                        completion(image, false, .none)
                    } else {
                        completion(.none, false, .downloadFailed)
                    }
                    strongSelf.finishDownload(imagePath: imagePath)
                }
            } else {
                completion(.none, false, .invalidUrl)
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func downloadImageAndCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            if let url = URL(string: strongSelf.urlAdaptedToSize(imagePath)), let data = try? Data(contentsOf: url) {
                // Save in cache
                let image = UIImage(data: data)
                if let unwrappedImage = image {
                    ContentCacheManager.shared.cacheImage(unwrappedImage, with: imagePath)
                }
                DispatchQueue.main.sync {
                    if let unwrappedImage = image {
                        completion(unwrappedImage, true, .none)
                    } else {
                        completion(.none, false, .downloadFailed)
                    }
                    strongSelf.finishDownload(imagePath: imagePath)
                }
            } else {
                completion(.none, false, .invalidUrl)
                strongSelf.finishDownload(imagePath: imagePath)
            }
        }
        self.pushForDownload(imagePath: imagePath, dispatchWorkItem: dispatchWorkItem)
    }
    
    private func retrieveImageFromCache(imagePath: String, completion: @escaping ImageDownloadCompletion) {
        // Retrieve image from cache
        self.cacheQueue.async {
            ContentCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                DispatchQueue.main.sync {
                    if let image = image {
                        completion(image, true, .none)
                    } else {
                        completion(.none, false, .notCached)
                    }
                }
            })
        }
    }
    
    private func pushForDownload(imagePath: String, dispatchWorkItem: DispatchWorkItem) {
        
        if let downloadItem = self.downloadPool[imagePath] {
            downloadItem.cancel()
            self.downloadPool.removeValue(forKey: imagePath)
        }
        
        self.downloadStack.append((imagePath, dispatchWorkItem))
        self.popForDownload()
    }
    
    private func popForDownload() {
        
        if downloadPool.count <= 3 {
            if let stackedDownload = self.downloadStack.popLast() {
                self.downloadPool[stackedDownload.0] = stackedDownload.1
                self.downloadQueue.async(execute: stackedDownload.1)
            }
        }
    }
    
    private func finishDownload(imagePath: String) {
        DispatchQueue.main.sync {
            self.downloadPool.removeValue(forKey: imagePath)
            self.popForDownload()
        }
    }
    
    private func urlAdaptedToSize(_ urlString: String) -> String {
        return UrlSizedComposserWrapper(urlString: urlString, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
    }

}
