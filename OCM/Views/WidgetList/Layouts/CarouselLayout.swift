//
//  CarouselLayout.swift
//  OCM
//
//  Created by Sergio López on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

struct CarouselLayout: LayoutDelegate {
    
    let collectionViewSize: CGSize
    
    init(collectionViewSize: CGSize) {
        self.collectionViewSize = collectionViewSize
    }
    
    func shouldShowPageController() -> Bool {
        return false
    }
    
    func sizeofContent(atIndexPath indexPath: IndexPath) -> CGSize {
        return collectionViewSize
    }
}
