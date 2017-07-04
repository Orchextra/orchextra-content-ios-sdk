//
//  ContentCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ContentCacheManager {
    
    /// Singleton
    static let shared = ContentCacheManager()
    
    /// Private properties
    private let cacheGroup = DispatchGroup()
    private let cacheQueue = DispatchQueue(label: "com.woah.contentCacheQueue", attributes: .concurrent)
    private var cachedContent: CachedContent
    
    private let reachability = ReachabilityWrapper.shared
    private let sectionLimit: Int
    private let elementsPerSectionLimit: Int
    private let firstSectionLimit: Int
    private var imageCacheManager: ImageCacheManager
    private let contentPersister: ContentPersister

    // MARK: - Lifecycle
    
    private init() {
        self.cachedContent = CachedContent()
        self.sectionLimit = 10
        self.elementsPerSectionLimit = 6
        self.firstSectionLimit = 12
        self.imageCacheManager = ImageCacheManager.shared
        self.contentPersister = ContentCoreDataPersister.shared
    }
    
    // MARK: - Private initialization methods
    
    // MARK: - Public methods
    
    /**
     Initializes the cache with the sections, contents and articles stored in the persistent store.
     */
    func initializeCache() {
        
        guard Config.offlineSupport else { return }
        // Initialization operation, readers must wait
        self.cacheGroup.enter()
        // Write operation, barrier
        self.cacheQueue.async(flags: .barrier) {
            let sections = self.contentPersister.loadContentPaths()
            for sectionPath in sections {
                self.cachedContent.cache[sectionPath] = []
                if let contents = self.contentPersister.loadContent(with: sectionPath)?.contents {
                    self.cache(contents: contents, with: sectionPath, fromPersistentStore: true)
                }
            }
            self.cacheGroup.leave()
        }
    }
    
    /**
     Deletes all the images related to the cached content, removing all referencres from disk and from 
     the persistent store.
     */
    func resetCache() {
        
        // Reset operation, readers must wait
        self.cacheGroup.enter()
        // Write operation, barrier
        self.cacheQueue.async(flags: .barrier) {
            self.imageCacheManager.cancelCaching()
            self.imageCacheManager.resetCache()
            self.cachedContent = CachedContent()
            self.cacheGroup.leave()
        }
    }
    
    /**
     Caches the given sections, adding the newest sections and removing those that no longer exist.
     
     - paramater sections: An array with the section's path, i.e.: content list path.
     */
    func cache(sections: [String]) {
    
        guard Config.offlineSupport else { return }
        // Initialization operation, readers must wait
        self.cacheGroup.enter()
        // Write operation, barrier
        self.cacheQueue.async(flags: .barrier) {
            
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
            self.cacheGroup.leave()
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
        
        // Initialization operation, readers must wait
        self.cacheGroup.enter()
        // Write operation, barrier
        self.cacheQueue.async {
            self.cache(contents: contents, with: sectionPath, fromPersistentStore: false)
            self.cacheGroup.leave()
        }
    }
    
    /**
     Initiates the caching process. All contents and articles in the cache that are pending to be cached will be
     downloaded from the server.
     */
    func startCaching() {
        
        guard Config.offlineSupport else { return }
        
        for sectionKey in self.cachedContent.cache.keys {
            self.startCaching(section: sectionKey)
        }
    }
    
    /**
     Initiates the caching process for given section. All images for a section contents and articles will be 
     retrived from the cache or downloaded from the server.
     */
    func startCaching(section sectionPath: String) {
        
        guard Config.offlineSupport else { return }

        self.cacheQueue.async {
            // Wait for initialization
            self.cacheGroup.wait()
            guard let contentCache = self.cachedContent.cache[sectionPath] else { return }
            for cachedContentDictionary in contentCache {
                for content in cachedContentDictionary.keys {
                    // Start content caching
                    if cachedContentDictionary[content]?.0 != .caching {
                        self.cache(content: content, with: sectionPath)
                    }
                    
                    // Start article caching
                    if cachedContentDictionary[content]?.1?.1 != .caching,
                        let article = cachedContentDictionary[content]?.1?.0 {
                        self.cache(article: article, for: content, with: sectionPath)
                    }
                }
            }
        }
    }

    /**
     Evaluates whether a content is currently cached or not.
 
     - parameter action: The content to evaluate.
     - returns: `true` if the content has a cached article or an article with no media, `false` otherwise.
     */
    func cachedArticle(for content: Content) -> Article? {

        var result: Article?
        self.cacheQueue.sync {
            // Wait for initialization
            self.cacheGroup.wait()
            guard
                Config.offlineSupport,
                let action = self.contentPersister.loadAction(with: content.elementUrl),
                let article = action as? ActionArticle else {
                    return
            }
            result = article.article
        }
        return result
    }
    
    /**
     Evaluates whether an image should be cached or not, regardless of it's current caching status.
     
     - parameter imagePath: `String` representation of the image's `URL`.
     */
    func shouldCacheImage(with imagePath: String) -> Bool {

        var result = false
        self.cacheQueue.sync {
            // Wait for initialization
            self.cacheGroup.wait()
            if self.cachedContent.cachedContentForImage(with: imagePath) != nil ||
                self.cachedContent.cachedArticleForImage(with: imagePath) != nil ||
                self.imageCacheManager.isImageCached(imagePath) != .none {
                result = true
            }
        }
        return result
    }
    
    /**
     Evaluates whether an image is currently in the cache or not.
     
     - parameter imagePath: `String` representation of the image's `URL`.
     - returns: `true` if it's already cached, `false` if it's not or if it's being cached.
     */
    func isImageCached(_ imagePath: String) -> Bool {

        switch self.imageCacheManager.isImageCached(imagePath) {
        case .cached:
            return true
        default:
            return false
        }
    }
    
    /**
     Retrieves from disk an image if it's cached.
     
     - paramater imagePath: `String` representation of the image's `URL`.
     - paramater completion: Completion handler to fire when looking for the image in cache is completed, 
     receiving the expected image or an error.
     */
    func cachedImage(with imagePath: String, completion: @escaping ImageCacheCompletion) {

        self.imageCacheManager.cachedImage(with: imagePath, completion: completion, priority: .high)
    }
    
    /**
     Saves an image on the cache.
     **Important**: This method should be called **only** for caching images shown on display, since it's 
     a heavy operation that scouts over the cache for determining it's associated content and article.
     
     - parameter image: Image to save in cache.
     - parameter imagePath: `String` representation of the image's `URL`.
     */
    func cacheImage(_ image: UIImage, with imagePath: String) {

        // TODO: Evaluate if this operation represents a risk for the safety of ImageCacheManager's queues.
        if let content = self.cachedContent.cachedContentForImage(with: imagePath) {
            self.imageCacheManager.cacheImage(image: image, with: imagePath, dependendency: content.slug)
        } else if let article = self.cachedContent.cachedArticleForImage(with: imagePath) {
            self.imageCacheManager.cacheImage(image: image, with: imagePath, dependendency: article.slug)
        }
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(contents: [Content], with sectionPath: String, fromPersistentStore: Bool = true) {
        
        let cacheStatus: ContentCacheStatus = fromPersistentStore ? .cachingFinished : .none
        let isFirstSection: Bool
        if let mainSectionPath = self.cachedContent.cache.first, mainSectionPath.key == sectionPath {
            isFirstSection = true
        } else {
            isFirstSection = false
        }
        // Cache the first `elementsPerSectionLimit` contents
        let elementsPerSectionLimit = isFirstSection ? self.firstSectionLimit : self.elementsPerSectionLimit
        for content in contents.prefix(elementsPerSectionLimit) {
            self.cachedContent.imagesForContent(content)
            var articleCache: ArticleCache?
            if let action = self.contentPersister.loadAction(with: content.elementUrl) {
                if let articleAction = action as? ActionArticle {
                    let article = articleAction.article
                    self.cachedContent.imagesForArticle(article)
                    articleCache = (article, cacheStatus)
                }
            }
            self.cachedContent.cache[sectionPath]?.append([content: (cacheStatus, articleCache)])
        }
    
    }
    
    private func cache(content: Content, with sectionPath: String, completion: ImageCacheCompletion? = nil) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }
        
        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .none
        // Cache content's media (thumbnail)
        if self.reachability.isReachableViaWiFi() {
            // If there's WiFi, start caching
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .caching
            if let imagePath = self.cachedContent.contentImages[content] {
                self.imageCacheManager.cacheImage(
                    for: imagePath,
                    withDependency: content.slug,
                    priority: .low,
                    completion: { (image, error) in
                        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .cachingFinished
                        completion?(image, error)
                })
            }
        } else {
            // If not, don't start caching until there's WiFi
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.0 = .none
        }
    }
    
    private func cache(article: Article, for content: Content, with sectionPath: String, completion: ImageCacheCompletion? = nil) {
        
        guard let contentIndex = self.cachedContent.indexOfContent(content: content, in: sectionPath) else { return }

        self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1 = (article, .none)
        // Cache article's image elements (thumbnail)
        if self.reachability.isReachableViaWiFi() {
            // If there's WiFi, start caching
            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1 = .caching
            if let imagePaths = self.cachedContent.articleImages[article] {
                for imagePath in imagePaths {
                    self.imageCacheManager.cacheImage(
                        for: imagePath,
                        withDependency: article.slug,
                        priority: .low,
                        completion: { (image, error) in
                            self.cachedContent.cache[sectionPath]?[contentIndex][content]?.1?.1 = .cachingFinished
                            completion?(image, error)
                    })
                }
            }
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
