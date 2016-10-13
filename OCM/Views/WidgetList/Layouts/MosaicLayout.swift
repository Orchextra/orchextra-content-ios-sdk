//
//  MosaicLayout.swift
//  OCM
//
//  Created by Sergio López on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol LayoutDelegate {
    
    func sizeofContent(atIndexPath indexPath: IndexPath) -> CGSize
    func shouldShowPageController() -> Bool
}

struct MosaicLayout: LayoutDelegate {
    
    let sizePattern: [CGSize]
    
    init(sizePattern: [CGSize]) {
        self.sizePattern = sizePattern
    }
    
    func shouldShowPageController() -> Bool {
        return false
    }

    func sizeofContent(atIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 1, height: 1)
    }
}
