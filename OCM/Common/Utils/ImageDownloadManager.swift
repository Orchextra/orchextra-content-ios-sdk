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
    
    // MARK: - Public methods
    
    /**
     Downloads an image with the provided path and sets it up on an `UIImageView`.
     If the `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter imageView: An `UIImageView` wehre the image will be set.
     - parameter placeholder: A placeholder image to use as the image is being downloaded or retrieved from OCM's cache. **Important**: Always set this placeholder when loading images in reusable cells, otherwise, the behaviour of
     what's on display will be faulty as you scroll on your Collection View or Table View.
     */
    class func downloadImage(with imagePath: String, in imageView: URLImageView, placeholder: UIImage?) {
        
        guard Config.offlineSupport, ImageCacheManager.shared.isImageCached(imagePath) else {
            self.downloadImageWithoutCache(imagePath: imagePath, in: imageView, placeholder: placeholder)
            return
        }
        
        // Set placeholder before getting image from cache
        imageView.image = placeholder
        DispatchQueue.global().async {
            ImageCacheManager.shared.cachedImage(
                with: imagePath,
                completion: { (image, _) in
                    guard let image = image else { return }
                    let resizedImage = imageView.imageAdaptedToSize(image: image)
                    DispatchQueue.main.async {
                        if imageView.url == imagePath {
                            UIView.transition(
                                with: imageView,
                                duration: 0.4,
                                options: .transitionCrossDissolve,
                                animations: {
                                    imageView.clipsToBounds = true
                                    imageView.contentMode = .scaleAspectFill
                                    imageView.image = resizedImage
                                },
                                completion: nil
                            )
                        }
                    }
            })
        }
    }
    
    /**
     Downloads an image with the provided path and fires the provided completion handler with the result.
     If the `offlineSupport` is enabled on OCM's configuration, it will use the one on cache if it's cached.
     
     - parameter imagePath: `String` representation for the image's path on server.
     - parameter completion: Completion handler to fire when download is completed, receiving the expected image
     or an error.
     */
    class func downloadImage(with imagePath: String, completion: @escaping ImageCacheCompletion) {
        
        guard Config.offlineSupport, ImageCacheManager.shared.isImageCached(imagePath) else {
            self.downloadImageWithoutCache(imagePath: imagePath, completion: completion)
            return
        }
        
        ImageCacheManager.shared.cachedImage(with: imagePath, completion: completion)
    }
    
    // MARK: - Private methods
    
    private class func downloadImageWithoutCache(imagePath: String, completion: @escaping ImageCacheCompletion) {
        
        let urlAdaptedToSize = UrlSizedComposserWrapper(urlString: imagePath, width: Int(UIScreen.main.bounds.width), height: nil, scaleFactor: Int(UIScreen.main.scale)).urlCompossed
        
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
    
    private class func downloadImageWithoutCache(imagePath: String, in imageView: UIImageView, placeholder: UIImage?) {
        
        imageView.imageFromURL(urlString: imageView.pathAdaptedToSize(path: imagePath), placeholder: placeholder)
    }

}
