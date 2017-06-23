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
 Tuple representing the caching status for an article. Where:
 - The `key` is an instance of `Article`.
 - The `value` is a `ContentCacheStatus` representing the caching status for the article.
 */
typealias ArticleCache = (Article, ContentCacheStatus)

/**
 Dictionary representing the caching status for a content. Where:
 - The `key` is the content.
 - The `value` is a tuple where:
 - The value for `0` is a `ContentCacheStatus` representing the caching status for the content.
 - The value for `1` is a tuple of type `ArticleCache` with the caching status for the content's article. **See:** `ArticleCache`
 */
typealias ContentCache = [Content: (ContentCacheStatus, ArticleCache?)]

/**
 Dictionary representing the caching status for sections. Where:
 - The `key` is the section's path, i.e.: content list path.
 - The `value` is a dictionary of type `ContentCache` with the caching status for section's contents. **See:** `ContentCache`
 */
typealias ContentCacheDictionary = [String: ContentCache]

class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()

    /// Private properties
    private let reachability: Reachability?
    private let sectionLimit: Int
    private let elementPerSectionLimit: Int
    private var contentCache: ContentCacheDictionary
    private var imageCacheManager: ImageCacheManager
    private let contentPersister: ContentPersister

    // MARK: - Lifecycle
    
    init() {
        
        self.reachability = Reachability()
        self.sectionLimit = 10
        self.elementPerSectionLimit = 21
        self.contentCache = ContentCacheDictionary()
        self.imageCacheManager = ImageCacheManager.shared
        self.contentPersister = ContentCoreDataPersister.shared
        
        // Listen to reachability changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: ReachabilityChangedNotification,
            object: reachability
        )
        
        try? self.reachability?.startNotifier()
        self.initializeCache()
    }
    
    deinit {
        // Stop listening to reachability changes
        self.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(
            self,
            name: ReachabilityChangedNotification,
            object: reachability)
    }
    
    // MARK: - Private initialization methods

    private func initializeCache() {
        
        guard Config.offlineSupport else { return }
        
        let sections = self.contentPersister.loadContentPaths()
        for sectionPath in sections {
            self.contentCache[sectionPath] = ContentCache()
            if let contents = self.contentPersister.loadContent(with: sectionPath)?.contents {
                self.cache(contents: contents, with: sectionPath)
            }
        }
    }
    
    // MARK: - Public methods
    
    /**
     Caches the given sections, adding the newest sections and removing those that no longer exist.
     
     - paramater sections: An array with the section's path, i.e.: content list path.
     */
    func cache(sections: [String]) {
    
        guard Config.offlineSupport else { return }
        
        let newSections = Set(sections)
        let oldSections = Set(self.contentCache.keys)
        
        // Remove from dictionary the old sections
        let sectionsToRemove = oldSections.subtracting(newSections)
        for sectionPath in sectionsToRemove {
            self.contentCache.removeValue(forKey: sectionPath)
            // TODO: Should we clean the cache at this point? maybe?
        }
        
        // Add to dictionary for caching the newest sections (restricted to `sectionLimit`)
        let sectionsToAdd = newSections.subtracting(oldSections)
        for sectionPath in sectionsToAdd where self.contentCache.count < self.sectionLimit {
            // Add to dictionary for caching
            self.contentCache[sectionPath] = ContentCache()
        }
    }
    
    /**
     Caches the contents for a given section (if the section is being cached).
     **Important:** This method will not fire any downloads to cache images. You'll need to call `startCaching`
     to fire that process.
     
     - paramater contents: An array of contents to be cached.
     - paramater sectionPath: The path for the corresponding section, i.e.: content list path.
     */
    func cache(contents: [Content], with sectionPath: String) {
        
        // Ignore if it's not on caching content
        guard Config.offlineSupport, self.contentCache[sectionPath] != nil else { return }
        
        // Cache the first `elementPerSectionLimit` contents
        for (index, content) in contents.enumerated() where index < self.elementPerSectionLimit {
            // If content is being cached, cancel caching for that content
            if let aux = self.contentCache[sectionPath]?[content]?.0, (aux == .caching || aux == .cachingPaused) {
                self.contentCache[sectionPath]?[content]?.0 = .cachingFinished
                self.imageCacheManager.cancelCachingWithDependency(content.slug)
            }
            self.contentCache[sectionPath]?[content]?.0 = .none //!!!
            //self.cache(content: content, sectionPath: sectionPath)
            if let action = self.contentPersister.loadAction(with: content.elementUrl) {
                if let article = action as? ActionArticle {
                    self.contentCache[sectionPath]?[content]?.1 = (article.article, .none) //!!!
                }
                //self.cache(action: action, for: content, with: sectionPath)
            }
        }
    }
    
    /**
     Add description !!!
     */
    
    func startCaching() {
        
        guard Config.offlineSupport else { return }
        
        //for (sectionKey, contentValue) in self.contentCache {
            //for content in contentValue.keys {
                // Start content caching
                // FIXME: !!!
                // self.contentCache[sectionKey]?[content]?.0 = .caching
                // self.cache(content: content, sectionPath: sectionKey)
                
                // Start article caching
                // let article = self.contentCache[sectionKey]?[content]?.1?.0
                // FIXME: !!!
                // self.contentCache[sectionKey]?[content]?.1.1 = .caching
                //self.cache(article: article, for: content)
            //}
        //}
    }
    
    /**
     Add description.
     */
    func pauseCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.contentCache {
            for content in contentValue.keys {
                // Pause content being cached
                if self.contentCache[sectionKey]?[content]?.0 == .caching {
                    self.contentCache[sectionKey]?[content]?.0 = .cachingPaused
                }
                // Pause articles being cached
                if self.contentCache[sectionKey]?[content]?.1?.1 == .caching {
                    self.contentCache[sectionKey]?[content]?.1?.1 = .cachingPaused
                }
            }
        }
        self.imageCacheManager.pauseCaching()
    }
    
    /**
     Add description.
     */
    func resumeCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.contentCache {
            for content in contentValue.keys {
                // Resume paused content caching
                if self.contentCache[sectionKey]?[content]?.0 == .cachingPaused {
                   // FIXME: !!!
                   // self.contentCache[sectionKey]?[content]?.0 = .caching
                   // self.cache(content: content, sectionPath: sectionKey)
                }
                // Resume paused article caching
                if self.contentCache[sectionKey]?[content]?.1?.1 == .cachingPaused {//,
                    //let article = self.contentCache[sectionKey]?[content]?.1 {
                    // FIXME: !!!
                    // self.contentCache[sectionKey]?[content]?.1.1 = .caching
                    //self.cache(article: article, for: content)
                }
            }
        }
        
        self.imageCacheManager.resumeCaching()
    }
    
    /**
     Add description.
     */
    func cancelCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.contentCache {
            for content in contentValue.keys {
                // Cancel content caching
                self.contentCache[sectionKey]?[content]?.0 = .cachingFinished

                // Cancel article caching
                self.contentCache[sectionKey]?[content]?.1?.1 = .cachingFinished
            }
        }
        self.imageCacheManager.cancelCaching()
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(action: Action, for content: Content, with sectionPath: String) {
        
        guard
            let article = action as? ActionArticle,
            self.contentCache[sectionPath]?[content] != nil
            else {
                return
        }
        
        self.cache(article: article.article, for: content, with: sectionPath)
    }
    
    private func cache(content: Content, sectionPath: String) {

        self.contentCache[sectionPath]?[content] = (.none, .none)
        
        // Cache content's media (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.contentCache[sectionPath]?[content]?.0 = .caching
            if let imagePath = self.pathForImagesInContent(content) {
                self.imageCacheManager.cacheImage(
                    for: imagePath,
                    withDependency: content.slug,
                    priority: .low,
                    completion: { (_, _) in
                        self.contentCache[sectionPath]?[content]?.0 = .cachingFinished
                })
            }
            
        } else {
            // If not, don't start caching until there's WiFi
            self.contentCache[sectionPath]?[content]?.0 = .none
        }
    }
    
    private func cache(article: Article, for content: Content, with sectionPath: String) {
        
        self.contentCache[sectionPath]?[content]?.1 = (article, .none)
        //self.contentCache[content]?.1 = [article: .none]

        // Cache article's image elements (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.contentCache[sectionPath]?[content]?.1?.1 = .caching
            if let imagePaths = self.pathForImagesInArticle(article) {
                for imagePath in imagePaths {
                    self.imageCacheManager.cacheImage(
                        for: imagePath,
                        withDependency: article.slug,
                        priority: .low,
                        completion: { (_, _) in
                            self.contentCache[sectionPath]?[content]?.1?.1 = .cachingFinished
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
