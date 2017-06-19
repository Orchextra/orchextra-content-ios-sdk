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
typealias ContentCacheDictionary = [Content: (ContentCacheStatus, [Article: ContentCacheStatus])]

//!!!
typealias NewContentCacheDictionary = [String: ([Content: ContentCacheStatus], [Article: ContentCacheStatus])]


class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()

    /// Private properties
    private let reachability: Reachability?
    private let sectionLimit: Int //!!!
    private let elementPerSectionLimit: Int //!!!
    private var contentCache: ContentCacheDictionary
    private var newContentCache: NewContentCacheDictionary
    private var imageCacheManager: ImageCacheManager

    // MARK: - Lifecycle
    
    init() {
        
        self.reachability = Reachability()
        self.sectionLimit = 10 // !!!
        self.elementPerSectionLimit = 21 // !!!
        self.contentCache = ContentCacheDictionary() // !!!
        self.newContentCache = [:]
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
    
    func cacheSections(_ sections: [String]) {
    
        for sectionPath in sections where self.newContentCache.count < self.sectionLimit {
            // Add to dictionary for caching
            self.newContentCache[sectionPath] = ([:], [:])
        }
    }

    
    func cacheContents(_ contents: [Content], sectionPath: String) {
        
        // Ignore if it's not on caching content
        guard self.newContentCache[sectionPath] != nil else { return }
        
        // Cache the first `elementPerSectionLimit` contents
        for (index, content) in contents.enumerated() where index < self.elementPerSectionLimit {
            // If content is being cached, cancel caching for that content
            if let aux = self.newContentCache[sectionPath]?.0[content], (aux == .caching || aux == .cachingPaused) {
                self.newContentCache[sectionPath]?.0[content] = .cachingFinished
                self.imageCacheManager.cancelCachingWithDependency(content.elementUrl)
            }
            self.cache(content: content, sectionPath: sectionPath) //!!!
        }
    }
    
//    // TODO: Document !!!
//    /**
//     Add description.
//     
//     - parameter contents: Add description
//     */
//    func cache(contents: ContentList) {
//        
//        let copy = self.contentCache
//        //self.contentCache = [:] // Replace ???
//        
//        // Cache the first `contentLimit` contents
//        for (index, content) in contents.contents.enumerated() where index < self.elementPerSectionLimit {
//            // If content is being cached, cancel caching for that content
//            if let aux = copy[content], (aux.0 == .caching || aux.0 == .cachingPaused) {
//                self.contentCache[content]?.0 = .cachingFinished
//                self.imageCacheManager.cancelCachingWithDependency(content.elementUrl)
//            }
//            self.cache(content: content)
//        }
//    }
    
    /**
     Add description.
     
     - parameter actions: Add description
     - parameter content: Add description
     */
    func cache(actions: [Action], for content: Content) {
        
        guard let cachingContent = self.contentCache[content] else { return }
        //self.contentCache[content]?.1 = [:] // Replace

        // Cache only articles
        let articles = actions.flatMap { (action) -> Article? in
            if let article = action as? ActionArticle {
                return article.article
            }
            return nil
        }
        
        // Cache the first `elementPerContentLimit` articles
        for (index, article) in articles.enumerated() where index < self.elementPerSectionLimit {
            // If article is being cached, cancel caching for that element
            if cachingContent.1[article] == .caching || cachingContent.1[article] == .cachingPaused {
                self.contentCache[content]?.1[article] = .cachingFinished
                self.imageCacheManager.cancelCachingWithDependency(article.slug)
            }
            self.cache(article: article, for: content)
        }
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
        for (contentKey, contentValue) in self.contentCache {
            if self.contentCache[contentKey]?.0 == .caching {
                self.contentCache[contentKey]?.0 = .cachingPaused
            }
            for (articleKey, _) in contentValue.1 where self.contentCache[contentKey]?.1[articleKey] == .caching {
                self.contentCache[contentKey]?.1[articleKey] = .cachingPaused
            }
        }
        self.imageCacheManager.pauseCaching()
    }
    
    // TODO: Document !!!
    /**
     Add description.
     */
    func resumeCaching() {
        for (contentKey, contentValue) in self.contentCache {
            if self.contentCache[contentKey]?.0 == .cachingPaused {
                //self.cache(content: contentKey) uncomment
            }
            for (articleKey, _) in contentValue.1 where self.contentCache[contentKey]?.1[articleKey] == .cachingPaused {
                self.contentCache[contentKey]?.1[articleKey] = .caching
            }
        }
        self.imageCacheManager.resumeCaching()
    }
    
    // TODO: Document !!!
    /**
     Add description.
     */
    func cancelCaching() {
        for (contentKey, contentValue) in self.contentCache {
            self.contentCache[contentKey]?.0 = .cachingFinished
            for (articleKey, _) in contentValue.1 {
                self.contentCache[contentKey]?.1[articleKey] = .cachingFinished
            }
        }
        self.imageCacheManager.cancelCaching()
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(content: Content, sectionPath: String) {

        self.newContentCache[sectionPath]?.0[content] = .none
        
        // Cache content's media (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.newContentCache[sectionPath]?.0[content] = .caching
                if let imagePath = self.pathForImagesInContent(content) {
                    self.imageCacheManager.cachedImage(
                        for: imagePath,
                        with: content.elementUrl,
                        priority: .low,
                        completion: { (_, error) in
                            self.newContentCache[sectionPath]?.0[content] = .cachingFinished
                    })
                }
            
        } else {
            // If not, don't start caching until there's WiFi
            self.newContentCache[sectionPath]?.0[content] = .none
        }
    }
    
    private func cache(article: Article, for content: Content) {
        
        //let cachingStatus = self.contentCache[content]?.1[article] !!! 666
        self.contentCache[content]?.1 = [article: .none]

        // Cache article's image elements (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.contentCache[content]?.1[article] = .caching
            if let imagePaths = self.pathForImagesInArticle(article) {
                for imagePath in imagePaths {
                    //if cachingStatus
                    self.imageCacheManager.cachedImage(
                        for: imagePath,
                        with: article.slug,
                        priority: .low,
                        completion: { (_, _) in
                            self.contentCache[content]?.1[article] = .cachingFinished
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
        
        let result = article.elements.flatMap { (element) -> String? in
            if let elementImage = element as? ElementImage {
                return elementImage.imageUrl
            } else if let button = element as? ElementButton {
                return button.backgroundImageURL
            }
            return nil
        }
        return result
    }
    
    private func updateCachingStatus(status: ContentCacheStatus) {
        
        for (contentKey, contentValue) in self.contentCache {
            self.contentCache[contentKey]?.0 = status
            for (articleKey, _) in contentValue.1 {
                self.contentCache[contentKey]?.1[articleKey] = status
            }
        }
    
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
