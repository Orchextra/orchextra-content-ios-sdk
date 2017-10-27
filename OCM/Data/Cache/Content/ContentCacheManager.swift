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
    private let cacheQueue = DispatchQueue(label: "com.woah.contentCacheManager.cacheQueue", attributes: .concurrent)
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
                self.cachedContent.initSection(sectionPath)
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
        // Critical write operation, no other processes are executed meanwhile
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
        // Critical write operation, no other processes are executed meanwhile
        self.cacheQueue.async(flags: .barrier) {

            let newSections = Set(sections)
            let oldSections = Set(self.cachedContent.cachedSections())
            
            // Remove from dictionary the old sections
            let sectionsToRemove = oldSections.subtracting(newSections)
            for sectionPath in sectionsToRemove {
                self.cachedContent.resetSection(sectionPath)
                // TODO: Should we clean the cache at this point? maybe?
            }
            
            // Add to dictionary for caching the newest sections (restricted to `sectionLimit`)
            let sectionsToAdd = newSections.subtracting(oldSections)
            for sectionPath in sectionsToAdd.prefix(self.sectionLimit) {
                // Add to dictionary for caching
                self.cachedContent.initSection(sectionPath)
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
    func cache(contents: [Content], with sectionPath: String, completion: @escaping () -> Void) {
        
        // Ignore if it's not on caching content
        guard Config.offlineSupport else { return }
        
        // Initialization operation, readers must wait
        self.cacheGroup.enter()
        self.cacheQueue.async(flags: .barrier) {
            self.cache(contents: contents, with: sectionPath, fromPersistentStore: false)
            self.cacheGroup.leave()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    /**
     Initiates the caching process. All contents and articles in the cache that are pending to be cached will be
     downloaded from the server.
     */
    func startCaching() {
        
        guard Config.offlineSupport, self.reachability.isReachableViaWiFi() else { return }
        
        self.cacheQueue.async {
            for sectionKey in self.cachedContent.cachedSections() {
                self.cache(section: sectionKey)
            }
        }
    }
    
    /**
     Initiates the caching process for given section. All images for a section contents and articles will be 
     retrived from the cache or downloaded from the server.
     */
    func startCaching(section sectionPath: String) {
        
        
        guard Config.offlineSupport, self.reachability.isReachableViaWiFi() else { return }

        self.cacheQueue.async {
            self.cacheGroup.wait()
            self.cache(section: sectionPath)
        }
    }

    /**
     Evaluates whether a content is currently cached or not.
 
     - parameter action: The content to evaluate.
     - returns: `true` if the content has a cached article or an article with no media, `false` otherwise.
     */
    func cachedArticle(for content: Content) -> Article? {

        var result: Article?
        guard
            Config.offlineSupport,
            let action = self.contentPersister.loadAction(with: content.elementUrl),
            let article = action as? ActionArticle else {
                return nil
        }
        result = article.article
        return result
    }
    
    /**
     Evaluates whether an image should be cached or not, regardless of it's current caching status.
     
     - parameter imagePath: `String` representation of the image's `URL`.
     */
    func shouldCacheImage(with imagePath: String) -> Bool {

        var result = false
        if self.cachedContent.cachedContentForImage(with: imagePath) != nil ||
            self.cachedContent.cachedArticleForImage(with: imagePath) != nil ||
            self.imageCacheManager.isImageCached(imagePath) != .none {
            result = true
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
     - parameter imageData: Data representation of the image.
     - parameter imagePath: `String` representation of the image's `URL`.
     */
    func cacheImage(_ image: UIImage, imageData: Data, with imagePath: String) {

        if let content = self.cachedContent.cachedContentForImage(with: imagePath) {
            self.imageCacheManager.cacheImage(image: image, imageData: imageData, with: imagePath, dependendency: content.slug)
        } else if let article = self.cachedContent.cachedArticleForImage(with: imagePath) {
            self.imageCacheManager.cacheImage(image: image, imageData: imageData, with: imagePath, dependendency: article.slug)
        }
    }
    
    // MARK: - Private helpers
    
    // MARK: Caching helpers
    
    private func cache(contents: [Content], with sectionPath: String, fromPersistentStore: Bool = true) {
        
        let cacheStatus: ContentCacheStatus = fromPersistentStore ? .cachingFinished : .none
        let isMainSection = self.cachedContent.isMainSection(sectionPath)
        // Cache the first `elementsPerSectionLimit` contents
        let elementsPerSectionLimit = isMainSection ? self.firstSectionLimit : self.elementsPerSectionLimit
        for content in contents.prefix(elementsPerSectionLimit) {
            self.cachedContent.setupImagesForContent(content)
            var articleCache: ArticleCache?
            if let action = self.contentPersister.loadAction(with: content.elementUrl) {
                if let articleAction = action as? ActionArticle {
                    let article = articleAction.article
                    self.cachedContent.setupImagesForArticle(article)
                    articleCache = (article, cacheStatus)
                }
            }
            self.cachedContent.updateSection(sectionPath, with: [content: (cacheStatus, articleCache)])
        }
    
    }
    
    private func cache(section sectionPath: String) {
        
        // Wait for initialization
        guard let contentCache = self.cachedContent.contentsForCachedSection(sectionPath) else { return }
        
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
    
    private func cache(content: Content, with sectionPath: String, completion: ImageCacheCompletion? = nil) {
        
        self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .none)
        // Cache content's media (thumbnail)
        if self.reachability.isReachableViaWiFi() {
            // If there's WiFi, start caching
            self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .caching)
            if let imagePath = self.cachedContent.imageForContent(content) {
                self.imageCacheManager.cacheImage(
                    for: imagePath,
                    withDependency: content.slug,
                    priority: .low,
                    completion: { (image, error) in
                        self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .cachingFinished)
                        completion?(image, error)
                })
            }
        }
    }
    
    private func cache(article: Article, for content: Content, with sectionPath: String, completion: ImageCacheCompletion? = nil) {
        
        self.cachedContent.updateContentArticle(sectionPath: sectionPath, content: content, value: (article, .none))
        // Cache article's image elements (thumbnail)
        if self.reachability.isReachableViaWiFi() {
            // If there's WiFi, start caching
            self.cachedContent.updateArticleStatus(sectionPath: sectionPath, content: content, value: .caching)
            if let imagePaths = self.cachedContent.imagesForArticle(article) {
                for imagePath in imagePaths {
                    self.imageCacheManager.cacheImage(
                        for: imagePath,
                        withDependency: article.slug,
                        priority: .low,
                        completion: { (image, error) in
                            self.cachedContent.updateArticleStatus(sectionPath: sectionPath, content: content, value: .cachingFinished)
                            completion?(image, error)
                    })
                }
            }
        }
    }
    
    func pauseCaching() {
        
        guard Config.offlineSupport else { return }
        
        for sectionPath in self.cachedContent.cachedSections() {
            guard let contentValue = self.cachedContent.contentsForCachedSection(sectionPath) else { return }
            for cachedContentDictionary in contentValue {
                for content in cachedContentDictionary.keys {
                    // Pause content being cached
                    if cachedContentDictionary[content]?.0 != .caching {
                        self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .cachingPaused)
                    }
                    // Pause articles being cached
                    if cachedContentDictionary[content]?.1?.1 != .caching {
                        self.cachedContent.updateArticleStatus(sectionPath: sectionPath, content: content, value: .cachingPaused)
                    }
                }
            }
        }
        self.imageCacheManager.pauseCaching()
    }
    
    func resumeCaching() {
        
        guard Config.offlineSupport else { return }
        
        for sectionPath in self.cachedContent.cachedSections() {
            guard let contentValue = self.cachedContent.contentsForCachedSection(sectionPath) else { return }
            for cachedContentDictionary in contentValue {
                for content in cachedContentDictionary.keys {
                    
                    // Resume paused content caching
                    if cachedContentDictionary[content]?.0 == .cachingPaused {
                        self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .caching)
                    }
                    
                    // Resume paused articles caching
                    if cachedContentDictionary[content]?.1?.1 != .cachingPaused {
                        self.cachedContent.updateArticleStatus(sectionPath: sectionPath, content: content, value: .caching)
                    }
                }
            }
        }
        
        self.imageCacheManager.resumeCaching()
    }
    
    func cancelCaching() {
        
        guard Config.offlineSupport else { return }
        
        for sectionPath in self.cachedContent.cachedSections() {
            guard let contentValue = self.cachedContent.contentsForCachedSection(sectionPath) else { return }
            for cachedContentDictionary in contentValue {
                for content in cachedContentDictionary.keys {
                    // Cancel content caching
                    self.cachedContent.updateContentStatus(sectionPath: sectionPath, content: content, value: .cachingFinished)
                    // Cancel article caching
                    self.cachedContent.updateArticleStatus(sectionPath: sectionPath, content: content, value: .cachingFinished)
                }
            }
        }
    }
    
}
