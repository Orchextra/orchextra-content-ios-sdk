//
//  ContentCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import Reachability

/**
 !!!
 */
enum ContentCacheStatus {
    case caching
    case cachingFinished
    case cachingPaused
    case none
}

class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()

    /// Private properties
    private let reachability = Reachability()
    private var status: ContentCacheStatus
    private var imageCacheManager: ImageCacheManager

    // MARK: - Lifecycle
    
    init() {
        self.status = .none
        self.imageCacheManager = ImageCacheManager()
        // Listen to reachability changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: ReachabilityChangedNotification,
            object: reachability
        )
        try? self.reachability?.startNotifier()
    }
    
    deinit {
        // Stop listening to reachability changes
        self.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(
            self,
            name: ReachabilityChangedNotification,
            object: reachability)
    }
    
    // MARK: - Public methods
    
    // TODO: Document !!!
    func cacheImage(for content: Content, in imageView: UIImageView) {
        
        // TODO: Implement !!!
        // This one should call the image cache manager with  high priority, being really careful with deadlocks, since the imageView might not be reference once it's competed
    }
    
    // TODO: We need to define exactly what our manager will be receiving!!! A list of Content, Actions, a JSON or whatever
    func startCaching() {
        
        guard self.status != .cachingPaused else {
            resumeCaching()
            return
        }

        self.status = .caching
        for element in self.contents() {
            self.imageCacheManager.cachedImage(
                for: element.0,
                with: element.1,
                priority: .low,
                completion: { (_, _) in
                    // FIXME: Should store the image on the database?! Maybe that should be done by the ImageCacheManager actually
            })
        } // TODO: Once this process is completed the status should change to finished
    }
    
    func pauseCaching() {
        
        guard self.status == .caching else { return }
        self.status = .cachingPaused
        self.imageCacheManager.pauseCaching()
    }
    
    func resumeCaching() {
    
        guard self.status == .cachingPaused else { return }
        self.status = .caching
        self.imageCacheManager.resumeCaching()
    }
    
    func cancelCaching() {
        
        guard self.status != .none else { return }
        self.status = .none
        self.imageCacheManager.cancelCaching()
    }
    
    // MARK: Reachability Change
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        
        guard let reachability = notification.object as? Reachability else { return }
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                // Start caching process when in WiFi
                self.resumeCaching()
            } else {
                // Stop caching process when in 3G, 4G, etc.
                self.pauseCaching()
            }
        } else {
            // Stop caching process ??? not sure about this, discuss
            self.cancelCaching()
        }
    }
    
}

extension ContentCacheManager {
    
    func contents() -> [(String, Content)] {
        
        let content = Content(slug: "prueba1",
                              tags: ["tag1"],
                              name: "title1",
                              media: Media(url: nil, thumbnail: nil),
                              elementUrl: ".",
                              requiredAuth: ".")
        let result = [("https://img-cm.orchextra.io/element/5938205a104dd202a479a894/preview/it/1496932354?originalwidth=1440&originalheight=2560", content),
                      ("https://img-cm.orchextra.io/element/5938205a104dd202a479a894/preview/it/1496932354?originalwidth=144&originalheight=256", content)]
        return result
    }
}
