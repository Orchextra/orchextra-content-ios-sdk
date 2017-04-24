//
//  CarouselLayout.swift
//  OCM
//
//  Created by Sergio López on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

struct CarouselLayout: LayoutDelegate {

    // MARK: - LayoutDelegate
    
    let type = Layout.carousel

    func shouldShowPageController() -> Bool {
        return true
    }
    
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize {
        return collectionView.size()
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        return CarouselFlowLayout()
    }
    
    func shouldPaginate() -> Bool {
        return true
    }
}
