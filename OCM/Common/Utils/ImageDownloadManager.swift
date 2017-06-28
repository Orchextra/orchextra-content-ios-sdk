//
//  ImageDownloadManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 22/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

/// Image download on completion receives the expected image or an error
typealias ImageDownloadCompletion = (UIImage?, ImageCacheError?) -> Void

class ImageDownloadManager {
    
    // MARK: Single
    static let shared = ImageDownloadManager()
    
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
        
        guard Config.offlineSupport, ContentCacheManager.shared.shouldCacheImage(with: imagePath) else {
            // If there's no offline support or the content is not cached, use UIImageView extension for downloading the image
            imageView.imageFromURL(urlString: imageView.pathAdaptedToSize(path: imagePath), placeholder: placeholder)
            return
        }
        
        imageView.image = placeholder
        if ImageCacheManager.shared.isImageCached(imagePath) {
            // If it's cached, retrieve and display
            self.retrieveImageFromCache(imagePath: imagePath, in: imageView, placeholder: placeholder)
        } else {
            // If it's not cached, download the image and save on cache
            self.downloadImageAndCache(imagePath: imagePath, in: imageView, placeholder: placeholder)
        }
    }
    
    /**
     Downloads an image with the provided path and fires the provided completion handler with the result.
     If the `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter completion: Completion handler to fire when download is completed, receiving the expected image
     or an error.
     */
    func downloadImage(with imagePath: String, completion: @escaping ImageCacheCompletion) {
        
        guard Config.offlineSupport, ContentCacheManager.shared.shouldCacheImage(with: imagePath) else {
            // If there's no offline support or the content is not cached, download the image
            self.downloadImage(imagePath: imagePath, completion: completion)
            return
        }
        
        if ImageCacheManager.shared.isImageCached(imagePath) {
            // If it's cached, retrieve and display
            self.retrieveImageFromCache(imagePath: imagePath, completion: completion)
        } else {
            // If it's not cached, download the image and save on cache
            self.downloadImageAndCache(imagePath: imagePath, completion: completion)
        }
        
        self.downloadImage(imagePath: imagePath) { (image, error) in
            if let unwrappedImage = image {
                DispatchQueue.global().async {
                    ContentCacheManager.shared.cacheImage(unwrappedImage, with: imagePath)
                }
                completion(image, error)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func retrieveImageFromCache(imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        // Retrieve image from cache
        DispatchQueue.global().async {
            ImageCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                guard let image = image else { return }
                let resizedImage = imageView.imageAdaptedToSize(image: image)
                DispatchQueue.main.async {
                    self.displayImage(resizedImage, with: imagePath, in: imageView)
                }
            })
        }
    }
    
    private func downloadImageAndCache(imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        // Download image
        let urlAdaptedToSize = UrlSizedComposserWrapper(urlString: imagePath, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
        DispatchQueue.global().async {
            if let url = URL(string: urlAdaptedToSize), let data = try? Data(contentsOf: url) {
                guard let image = UIImage(data: data) else { return }
                // Save in cache
                ContentCacheManager.shared.cacheImage(image, with: imagePath)
                let resizedImage = imageView.imageAdaptedToSize(image: image)
                DispatchQueue.main.async {
                    self.displayImage(resizedImage, with: imagePath, in: imageView)
                }
            }
        }
    }
    
    private func displayImage(_ image: UIImage?, with imagePath: String, in imageView: URLImageView) {
        // Display image in URLImageView
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
    
    private func downloadImage(imagePath: String, completion: @escaping ImageCacheCompletion) {
        
        let urlAdaptedToSize = UrlSizedComposserWrapper(urlString: imagePath, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
        // Download image
        DispatchQueue.global().async {
            if let url = URL(string: urlAdaptedToSize), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        completion(image, .none)
                    } else {
                        completion(.none, .downloadFailed)
                    }
                }
            } else {
                completion(.none, .invalidUrl)
            }
        }
    }
    
    private func downloadImageAndCache(imagePath: String, completion: @escaping ImageCacheCompletion) {
        
        let urlAdaptedToSize = UrlSizedComposserWrapper(urlString: imagePath, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
        // Download image
        DispatchQueue.global().async {
            if let url = URL(string: urlAdaptedToSize), let data = try? Data(contentsOf: url) {
                // Save in cache
                let image = UIImage(data: data)
                if let unwrappedImage = image {
                    ContentCacheManager.shared.cacheImage(unwrappedImage, with: imagePath)
                }
                DispatchQueue.main.async {
                    if let unwrappedImage = image {
                        completion(unwrappedImage, .none)
                    } else {
                        completion(.none, .downloadFailed)
                    }
                }
            } else {
                completion(.none, .invalidUrl)
            }
        }
    }
    
    private func retrieveImageFromCache(imagePath: String, completion: @escaping ImageCacheCompletion) {
        // Retrieve image from cache
        DispatchQueue.global().async {
            ImageCacheManager.shared.cachedImage(with: imagePath, completion: { (image, _) in
                DispatchQueue.main.async {
                    if let image = image {
                        completion(image, .none)
                    } else {
                        completion(.none, .cachingFailed)
                    }
                }
            })
        }
    }

}
