//
//  CachedContent.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 26/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/**
 Status of the caching process of images for a content or an article.
 
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
typealias ContentCacheDictionary = [String: [ContentCache]]

class CachedContent {

    // Private properties
    
    private var cacheQueue = DispatchQueue(label: "com.woah.cachedContentQueue", attributes: .concurrent)
    private var _cache: ContentCacheDictionary = [:]
    private var cache: ContentCacheDictionary {
        var copy: ContentCacheDictionary?
        self.cacheQueue.sync {
            copy = self._cache
        }
        return copy ?? [:]
    }
    
    private var contentImagesQueue = DispatchQueue(label: "com.woah.contentImagesContentQueue", attributes: .concurrent)
    private var _contentImages: [Content: String] = [:]
    private var contentImages: [Content: String] {
        var copy: [Content: String]?
        self.contentImagesQueue.sync {
            copy = self._contentImages
        }
        return copy ?? [:]
    }
    
    private var articleImagesQueue = DispatchQueue(label: "com.woah.articleImagesContentQueue", attributes: .concurrent)
    private var _articleImages: [Article: [String]] = [:]
    private var articleImages: [Article: [String]] {
        var copy: [Article: [String]]?
        self.articleImagesQueue.sync {
            copy = self._articleImages
        }
        return copy ?? [:]
    }
    
    // MARK: - Public methods
    
    // MARK: Getters
    
    func cachedContentForImage(with imagePath: String) -> Content? {
        
        for (key, value) in self.contentImages where value == imagePath {
            return key
        }
        return nil
    }
    
    func cachedArticleForImage(with imagePath: String) -> Article? {
        
        for (key, value) in self.articleImages where value.contains(imagePath) {
            return key
        }
        return nil
    }
    
    func isSectionCached(_ sectionPath: String) -> Bool {
        return self.cache[sectionPath] != nil
    }
    
    func isMainSection(_ sectionPath: String) -> Bool {
        if let mainSectionPath = self.cache.first, mainSectionPath.key == sectionPath {
            return  true
        }
        return false
    }
    
    func cachedSections() -> [String] {
        return Array(self.cache.keys)
    }
    
    func contentsForCachedSection(_ sectionPath: String) -> [ContentCache]? {
        return self.cache[sectionPath]
    }
    
    func articlesForCachedSection(_ sectionPath: String) -> [ArticleCache]? {
        
        guard let contentCache = self.cache[sectionPath] else { return nil }
        for cachedContentDictionary in contentCache {
            var articles: [ArticleCache] = []
            for content in cachedContentDictionary.keys {
                if let article = cachedContentDictionary[content]?.1 {
                    articles.append(article)
                }
            }
            return articles
        }
        return nil
    }
    
    func sectionForCachedContent(_ content: Content) -> String? {
        
        for (sectionPath, value) in self.cache {
            for cachedContentDictionary in value {
                if cachedContentDictionary.contains(where: { $0.key == content }) {
                    return sectionPath
                }
            }
        }
        return nil
    }
    
    func sectionAndContentForCachedArticle(_ article: Article) -> (String, Content)? {
        
        for (sectionPath, value) in self.cache {
            for cachedContentDictionary in value {
                for (content, cachedArticle) in cachedContentDictionary where cachedArticle.1?.0 == article {
                    return (sectionPath, content)
                }
            }
        }
        return nil
    }
    
    func isCached(article: Article) -> Bool {
    
        for contentValue in self.cache.values {
            for cachedContentDictionary in contentValue {
                for cachedArticle in cachedContentDictionary.values where cachedArticle.1?.0 == article {
                    return true
                }
            }
        }
        // Check if there's media
        let containsMedia = article.elements .contains(where: { (element) -> Bool in
            guard element is ElementImage || element is ElementHeader || element is ElementVideo || element is ElementButton else { return false }
            return true
        })
        let preview = article.preview as? PreviewImageText
        // If there's no media, it's cached
        if !containsMedia, preview == nil {
            return true
        }
        return false
    }
    
    // MARK: Setters
    
    func initSection(_ sectionPath: String) {
        self.cacheQueue.async(flags: .barrier) {
            self._cache[sectionPath] = []
        }
    }
    
    func resetSection(_ sectionPath: String) {
        self.cacheQueue.async(flags: .barrier) {
            self._cache.removeValue(forKey: sectionPath)
        }
    }
    
    func updateSection(_ sectionPath: String, with value: ContentCache) {
        self.cacheQueue.async(flags: .barrier) {
            self._cache[sectionPath]?.append(value)
        }
    }
    
    func updateContentStatus(sectionPath: String, content: Content, value: ContentCacheStatus) {
        
        guard let contentIndex = self.indexOfContent(content: content, in: sectionPath) else { return }
        self.cacheQueue.async(flags: .barrier) {
            self._cache[sectionPath]?[contentIndex][content]?.0 = .none
        }
    }
    
    func updateContentArticle(sectionPath: String, content: Content, value: ArticleCache) {
        guard let contentIndex = self.indexOfContent(content: content, in: sectionPath) else { return }
        self.cacheQueue.async(flags: .barrier) {
            self._cache[sectionPath]?[contentIndex][content]?.1 = value
        }
    }

    func updateArticleStatus(sectionPath: String, content: Content, value: ContentCacheStatus) {
        guard let contentIndex = self.indexOfContent(content: content, in: sectionPath) else { return }
        self.cacheQueue.async(flags: .barrier) {
            self._cache[sectionPath]?[contentIndex][content]?.1?.1 = .caching
        }
    }
    
    func setupImagesForContent(_ content: Content) {
        
        let imagePath = content.media.url
        self.contentImagesQueue.async(flags: .barrier) {
            self._contentImages[content] = imagePath
        }
    }
    
    func imageForContent(_ content: Content) -> String? {
        
        return self.contentImages[content]
    }
    
    func setupImagesForArticle(_ article: Article) {
        
        var result = article.elements.flatMap { (element) -> String? in
            if let elementImage = element as? ElementImage {
                return elementImage.imageUrl
            } else if let button = element as? ElementButton {
                return button.backgroundImageURL
            } else if let header = element as? ElementHeader {
                return header.imageUrl
            } else if let video = element as? ElementVideo {
                return video.videoView?.video?.previewUrl
            }
            return nil
        }
        if let preview = article.preview as? PreviewImageText, let imageUrl = preview.imageUrl {
            result.append(imageUrl)
        }
        self.articleImagesQueue.async(flags: .barrier) {
            self._articleImages[article] = result
        }
    }
    
    func imagesForArticle(_ article: Article) -> [String]? {
        
        return self.articleImages[article]
    }
    
    // MARK: - Private helpers
    
    private func indexOfContent(content: Content, in sectionPath: String) -> Int? {
        
        let index = self.cache[sectionPath]?.index(where: { (cachedContentDictionary) -> Bool in
            return cachedContentDictionary[content] != nil
        })
        return index
    }
    
}
