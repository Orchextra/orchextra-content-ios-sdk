//
//  CachedContent.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 26/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

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
typealias ContentCacheDictionary = [String: [ContentCache]]

class CachedContent {

    var cache: ContentCacheDictionary = [:]
    
    func indexOfContent(content: Content, in sectionPath: String) -> Int? {
        
        let index = self.cache[sectionPath]?.index(where: { (cachedContentDictionary) -> Bool in
            return cachedContentDictionary[content] != nil
        })
        return index
    }
    
    func isCached(article: Article) -> Bool {
    
        for contentValue in self.cache.values {
            for cachedContentDictionary in contentValue {
                for cachedArticle in cachedContentDictionary.values where cachedArticle.1?.0 == article && cachedArticle.1?.1 == .cachingFinished {
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
    
}
