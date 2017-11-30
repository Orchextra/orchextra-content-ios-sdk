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
 - Since: 2.1.3
 - Author: Pablo Viciano Negre
 - Copyright: Gigigo S.L.
 */
open class OfflineSupportConfig: NSObject {
    /**
     Cache section limit. Set to limit the number of sections that are cached. Must be positive or zero
     */
    let cacheSectionLimit: UInt
    /**
     Cache elements per section limit. Set to limit the max number of elements that are cached per section. Must be positive or zero
     */
    let cacheElementsPerSectionLimit: UInt
    /**
     Cache first section Limit. Set to limit the max number of elements cached inside the first section. Must be positive or zero
     */
    let cacheFirstSectionLimit: UInt
    
    public init(cacheSectionLimit: UInt, cacheElementsPerSectionLimit: UInt, cacheFirstSectionLimit: UInt) {
        self.cacheSectionLimit = cacheSectionLimit
        self.cacheElementsPerSectionLimit = cacheElementsPerSectionLimit
        self.cacheFirstSectionLimit = cacheFirstSectionLimit
    }
}
