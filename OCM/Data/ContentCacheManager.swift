//
//  ContentCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import Reachability
import GIGLibrary

/**
 Status of the caching progress of images for a content or an article.
 
 - caching: the caching process is in progress.
 - cachingFinished: the caching process finished, succesfully or not.
 - cachingPaused: the caching process is paused.
 - none: the caching process is pending and has not started yet.
 */
enum ContentCacheStatus {
    case caching
    case cachingFinished
    case cachingPaused
    case none
}

/**
 Dictionary representing the status for the content caching process. Where:
 - The `key` is an instance of `Content`.
 - The `value` is a tuple of type `(Bool, [Article: Bool])`.
 Where the latter tuple:
 - The value for `0` is a `ContentCacheStatus` representing the caching status for the content.
 - The value for `1` is a dictionary of type `[Article: Bool]`.
 Where the latter dictionary:
 - The `key` is an instance of `Article`.
 - The `value` is a `ContentCacheStatus` representing the caching status for the article.
 */
//typealias ContentCacheDictionary = [Content: (ContentCacheStatus, [Article: ContentCacheStatus])]

//!!!
typealias ArticleCache = (Article, ContentCacheStatus)
typealias ContentCache = [Content: (ContentCacheStatus, ArticleCache?)]
typealias ContentCacheDictionary = [String: ContentCache]


class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()

    /// Private properties
    private let reachability: Reachability?
    private let sectionLimit: Int
    private let elementPerSectionLimit: Int
    private var newContentCache: ContentCacheDictionary
    private var imageCacheManager: ImageCacheManager
    private let contentPersister: ContentPersister

    // MARK: - Lifecycle
    
    init() {
        
        self.reachability = Reachability()
        self.sectionLimit = 10
        self.elementPerSectionLimit = 21
        self.newContentCache = ContentCacheDictionary()
        self.imageCacheManager = ImageCacheManager()
        self.contentPersister = ContentCoreDataPersister.shared
        
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
    
    // MARK: - Private setup methods
    
    private func initializeContentCache() {
        
        let sections = self.contentPersister.loadContentPaths()
        for sectionPath in sections {
            self.newContentCache[sectionPath] = ContentCache()
            if let contents = self.contentPersister.loadContent(with: sectionPath)?.contents {
                self.cache(contents: contents, with: sectionPath)
            }
        }
    }
    
    // MARK: - Public methods
    
    func cache(sections: [String]) {
    
        // Replaces sections
        for (index, sectionPath) in sections.enumerated() where index < self.sectionLimit {
            // Add to dictionary for caching
            self.newContentCache[sectionPath] = ContentCache()
        }
    }
    
    func cache(contents: [Content], with sectionPath: String) {
        
        // Ignore if it's not on caching content
        guard self.newContentCache[sectionPath] != nil else { return }
        
        // Cache the first `elementPerSectionLimit` contents
        for (index, content) in contents.enumerated() where index < self.elementPerSectionLimit {
            // If content is being cached, cancel caching for that content
            if let aux = self.newContentCache[sectionPath]?[content]?.0, (aux == .caching || aux == .cachingPaused) {
                self.newContentCache[sectionPath]?[content]?.0 = .cachingFinished
                self.imageCacheManager.cancelCachingWithDependency(content.elementUrl)
            }
            self.cache(content: content, sectionPath: sectionPath)
            if let action = self.contentPersister.loadAction(with: content.elementUrl) {
                self.cache(action: action, for: content, with: sectionPath)
            }
        }
    }
    
    /**
     Add description.
     
     - parameter action: Add description
     - parameter content: Add description
     - parameter sectionPath: Add description
     */
    func cache(action: Action, for content: Content, with sectionPath: String) {
        
        guard
            let article = action as? ActionArticle,
            self.newContentCache[sectionPath]?[content] != nil
            else {
            return
        }
        
        self.cache(article: article.article, for: content, with: sectionPath)
    }
    
    // TODO: Document !!!
    /**
     Add description.
     
     - parameter content: Add description
     - parameter imageView: Add description
     */
    func cacheImage(for content: Content, in imageView: UIImageView) {
        
        // TODO: Implement !!!
        // This one should call the image cache manager with  high priority, being really careful with deadlocks, since the imageView might not be reference once it's competed
    }
    
    // TODO: Document !!!
    /**
     Add description.
     */
    func pauseCaching() {
        for (sectionKey, contentValue) in self.newContentCache {
            for content in contentValue.keys {
                // Pause content being cached
                if self.newContentCache[sectionKey]?[content]?.0 == .caching {
                    self.newContentCache[sectionKey]?[content]?.0 = .cachingPaused
                }
                // Pause articles being cached
                if self.newContentCache[sectionKey]?[content]?.1?.1 == .caching {
                    self.newContentCache[sectionKey]?[content]?.1?.1 = .cachingPaused
                }
            }
        }
        self.imageCacheManager.pauseCaching()
    }
    
    // TODO: Document !!!
    /**
     Add description.
     */
    func resumeCaching() {
        
        for (sectionKey, contentValue) in self.newContentCache {
            for content in contentValue.keys {
                // Resume paused content caching
                if self.newContentCache[sectionKey]?[content]?.0 == .cachingPaused {
                   // FIXME: !!!
                   // self.newContentCache[sectionKey]?[content]?.0 = .caching
                   // self.cache(content: content, sectionPath: sectionKey)
                }
                // Resume paused article caching
                if self.newContentCache[sectionKey]?[content]?.1?.1 == .cachingPaused,
                    let article = self.newContentCache[sectionKey]?[content]?.1 {
                    // FIXME: !!!
                    // self.newContentCache[sectionKey]?[content]?.1.1 = .caching
                    //self.cache(article: article, for: content)
                }
            }
        }
        
        self.imageCacheManager.resumeCaching()
    }
    
    // TODO: Document !!!
    /**
     Add description.
     */
    func cancelCaching() {
        
        for (sectionKey, contentValue) in self.newContentCache {
            for content in contentValue.keys {
                // Cancel content caching
                self.newContentCache[sectionKey]?[content]?.0 = .cachingFinished

                // Cancel article caching
                self.newContentCache[sectionKey]?[content]?.1?.1 = .cachingFinished
            }
        }
        self.imageCacheManager.cancelCaching()
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(content: Content, sectionPath: String) {

        self.newContentCache[sectionPath]?[content] = (.none, .none)
        
        // Cache content's media (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.newContentCache[sectionPath]?[content]?.0 = .caching
            if let imagePath = self.pathForImagesInContent(content) {
                self.imageCacheManager.cachedImage(
                    for: imagePath,
                    with: content.elementUrl,
                    priority: .low,
                    completion: { (_, _) in
                        self.newContentCache[sectionPath]?[content]?.0 = .cachingFinished
                })
            }
            
        } else {
            // If not, don't start caching until there's WiFi
            self.newContentCache[sectionPath]?[content]?.0 = .none
        }
    }
    
    private func cache(article: Article, for content: Content, with sectionPath: String) {
        
        self.newContentCache[sectionPath]?[content]?.1 = (article, .none)
        //self.contentCache[content]?.1 = [article: .none]

        // Cache article's image elements (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.newContentCache[sectionPath]?[content]?.1?.1 = .caching
            if let imagePaths = self.pathForImagesInArticle(article) {
                for imagePath in imagePaths {
                    self.imageCacheManager.cachedImage(
                        for: imagePath,
                        with: article.slug,
                        priority: .low,
                        completion: { (_, _) in
                            self.newContentCache[sectionPath]?[content]?.1?.1 = .cachingFinished
                    })
                }
            }
        }
    }
    
    // MARK: Handy helpers
    
    private func pathForImagesInContent(_ content: Content) -> String? {
        
        return content.media.url
    }
    
    private func pathForImagesInArticle(_ article: Article) -> [String]? {
        
        var result = article.elements.flatMap { (element) -> String? in
            if let elementImage = element as? ElementImage {
                return elementImage.imageUrl
            } else if let button = element as? ElementButton {
                return button.backgroundImageURL
            } else if let header = element as? ElementHeader {
                return header.imageUrl
            }
            return nil
        }
        if let preview = article.preview as? PreviewImageText, let imageUrl = preview.imageUrl {
            result.append(imageUrl)
        }
        return result
    }
    
    // MARK: - Reachability Change
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        
//        guard let reachability = notification.object as? Reachability else { return }
//        
//        if reachability.isReachable {
//            if reachability.isReachableViaWiFi {
//                // Start caching process when in WiFi
//                self.resumeCaching()
//            } else {
//                // Stop caching process when in 3G, 4G, etc.
//                self.pauseCaching()
//            }
//        } else {
//            // Stop caching process ??? not sure about this, discuss
//            self.cancelCaching()
//        }
    }
    
}
