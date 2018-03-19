//
//  FullScreenLayout.swift
//  OCM
//
//  Created by José Estela on 19/3/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

struct FullScreenLayout: Layout {
    
    // MARK: - Layout
    
    let type = LayoutType.fullscreen
    
    func shouldShowPageController() -> Bool {
        return false
    }
    
    func shouldPullToRefresh() -> Bool {
        return true
    }
    
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize {
        return collectionView.size()
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        return FullScreenFlowLayout()
    }
    
    func shouldPaginate() -> Bool {
        return true
    }
    
    func shouldAutoPlay() -> Bool {
        return false
    }
}
