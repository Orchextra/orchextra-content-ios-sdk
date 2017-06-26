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

class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()

    /// Private properties
    private let reachability: Reachability?
    private let sectionLimit: Int
    private let elementPerSectionLimit: Int
    private var cachedContent: CachedContent
    private var imageCacheManager: ImageCacheManager
    private let contentPersister: ContentPersister

    // MARK: - Lifecycle
    
    init() {
        
        self.reachability = Reachability()
        self.sectionLimit = 10
        self.elementPerSectionLimit = 21
        self.cachedContent = CachedContent()
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
        // self.initializeCache()
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

    // FIXME: No longer private, determine when would it be best to initialize the cache if nothing is there !!!
    func initializeCache() {
        
        guard Config.offlineSupport else { return }
        
        let sections = self.contentPersister.loadContentPaths()
        for sectionPath in sections {
            self.cachedContent.cache[sectionPath] = []
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
        let oldSections = Set(self.cachedContent.cache.keys)
        
        // Remove from dictionary the old sections
        let sectionsToRemove = oldSections.subtracting(newSections)
        for sectionPath in sectionsToRemove {
            self.cachedContent.cache.removeValue(forKey: sectionPath)
            
            // TODO: Should we clean the cache at this point? maybe?
        }
        
        // Add to dictionary for caching the newest sections (restricted to `sectionLimit`)
        let sectionsToAdd = newSections.subtracting(oldSections)
        for sectionPath in sectionsToAdd where self.cachedContent.cache.count < self.sectionLimit {
            // Add to dictionary for caching
            self.cachedContent.cache[sectionPath] = []
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
        guard Config.offlineSupport, self.cachedContent.cache[sectionPath] != nil else { return }
        
        // Cache the first `elementPerSectionLimit` contents
        for content in contents.prefix(elementPerSectionLimit) {
            self.cancelCachingForContent(content, in: sectionPath) // cancel caching for that content, if any            
            var articleCache: ArticleCache?
            if let action = self.contentPersister.loadAction(with: content.elementUrl) {
                if let article = action as? ActionArticle {
                    self.cancelCachingArticle(article.article, with: content, in: sectionPath) // cancel caching for that article, if any
                    articleCache = (article.article, .none)
                }
            }
            self.cachedContent.cache[sectionPath]?.append([content: (.none, articleCache)])
        }
    }
    
    /**
     Initializes the caching process. All contents and articles in the cache that are pending to be cached will be
     downloaded from the server.
     */
    func startCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.cachedContent.cache {
            for cachedContentDictionary in contentValue {
                for content in cachedContentDictionary.keys {
                    // Start content caching
                    if cachedContentDictionary[content]?.0 != .caching {
                        self.cache(content: content, sectionPath: sectionKey)
                    }
                    
                    // Start article caching
                    if cachedContentDictionary[content]?.1?.1 != .caching,
                        let article = cachedContentDictionary[content]?.1?.0 {
                        self.cache(article: article, for: content, with: sectionKey)
                    }
                }
            }
        }
    }
    
    /**
     Evaluates whether an action is currently cached or not.
     
     - parameter action: The action to evaluate.
     - returns: `true` if the action is a cached article or an article with no media, `false` otherwise.
     */
    func isCached(action: Action) -> Bool {
    
        guard
            let articleAction = action as? ActionArticle,
            self.cachedContent.isCached(article: articleAction.article)
        else {
            return false
        }
        return true
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(content: Content, sectionPath: String) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }
        
        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .none
        
        // Cache content's media (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .caching
            if let imagePath = self.pathForImagesInContent(content) {
                self.imageCacheManager.cacheImage(
                    for: imagePath,
                    withDependency: content.slug,
                    priority: .low,
                    completion: { (_, _) in
                        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .cachingFinished
                })
            }
        } else {
            // If not, don't start caching until there's WiFi
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .none
        }
    }
    
    private func cache(article: Article, for content: Content, with sectionPath: String) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }

        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1 = (article, .none)

        // Cache article's image elements (thumbnail)
        if let reachability = self.reachability, reachability.isReachableViaWiFi {
            // If there's WiFi, start caching
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1 = .caching
            if let imagePaths = self.pathForImagesInArticle(article) {
                for imagePath in imagePaths {
                    self.imageCacheManager.cacheImage(
                        for: imagePath,
                        withDependency: article.slug,
                        priority: .low,
                        completion: { (_, _) in
                            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1 = .cachingFinished
                    })
                }
            }
        }
    }
    
    private func cancelCachingForContent(_ content: Content, in sectionPath: String) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }

        if let aux = self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0, (aux == .caching || aux == .cachingPaused) {
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .cachingFinished
            self.imageCacheManager.cancelCachingWithDependency(content.slug)
        }
    }
    
    private func cancelCachingArticle(_ article: Article, with content: Content, in sectionPath: String) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }

        if let aux = self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1, (aux == .caching || aux == .cachingPaused) {
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1 = .cachingFinished
            self.imageCacheManager.cancelCachingWithDependency(article.slug)
        }
    }
    
    func pauseCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.cachedContent.cache {
            for (index, cachedContentDictionary) in contentValue.enumerated() {
                for content in cachedContentDictionary.keys {
                    // Pause content being cached
                    if cachedContentDictionary[content]?.0 != .caching {
                        self.cachedContent.cache[sectionKey]?[index][content]?.0 = .cachingPaused
                    }
                    // Pause articles being cached
                    if cachedContentDictionary[content]?.1?.1 != .caching {
                        self.cachedContent.cache[sectionKey]?[index][content]?.1?.1 = .cachingPaused
                    }
                }
            }
        }
        self.imageCacheManager.pauseCaching()
    }
    
    func resumeCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.cachedContent.cache {
            for (index, cachedContentDictionary) in contentValue.enumerated() {
                for content in cachedContentDictionary.keys {
                    
                    // Resume paused content caching
                    if cachedContentDictionary[content]?.0 == .cachingPaused {
                        self.cachedContent.cache[sectionKey]?[index][content]?.0 = .caching
                    }
                    
                    // Resume paused articles caching
                    if cachedContentDictionary[content]?.1?.1 != .cachingPaused {
                        self.cachedContent.cache[sectionKey]?[index][content]?.1?.1 = .caching
                    }
                }
            }
        }
        
        self.imageCacheManager.resumeCaching()
    }
    
    func cancelCaching() {
        
        guard Config.offlineSupport else { return }
        
        for (sectionKey, contentValue) in self.cachedContent.cache {
            for (index, cachedContentDictionary) in contentValue.enumerated() {
                for content in cachedContentDictionary.keys {
                    
                    // Cancel content caching
                    self.cachedContent.cache[sectionKey]?[index][content]?.0 = .cachingFinished
                    
                    // Cancel article caching
                    self.cachedContent.cache[sectionKey]?[index][content]?.1?.1 = .cachingFinished
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
//        }
    }
    
}
