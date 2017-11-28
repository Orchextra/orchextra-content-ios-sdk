//
//  OfflineSupportConfig.swift
//  OCM
//
//  Created by Pablo Viciano Negre on 29/11/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
/**
 The OfflineSupportConfig can be used to set the maximum elements cached locally
 - Since: 2.1.2
 - Author: Pablo Viciano Negre
 - Copyright: Gigigo S.L.
 */
open class OfflineSupportConfig: NSObject {
    /**
     Cache section limit. Set to limit the number of sections that are cached.
     */
    let cacheSectionLimit: Int
    /**
     Cache elements per section limit. Set to limit the max number of elements that are cached per section
     */
    let cacheElementsPerSectionLimit: Int
    /**
     Cache first section Limit. Set to limit the max number of elements cached inside the first section.
     */
    let cacheFirstSectionLimit: Int
    
    public init(cacheSectionLimit: Int, cacheElementsPerSectionLimit: Int, cacheFirstSectionLimit: Int) {
        self.cacheSectionLimit = cacheSectionLimit
        self.cacheElementsPerSectionLimit = cacheElementsPerSectionLimit
        self.cacheFirstSectionLimit = cacheFirstSectionLimit
    }
}
