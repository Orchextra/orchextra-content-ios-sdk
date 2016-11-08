//
//  MosaicLayout.swift
//  OCM
//
//  Created by Sergio López on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

struct MosaicLayout: LayoutDelegate, MosaicFlowLayoutDelegate {
    
    let type = Layout.mosaic
    
    let sizePattern: [CGSize]
    
    // MARK: - LayoutDelegate
    
    func shouldShowPageController() -> Bool {
        return false
    }

    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize {
        let index = indexPath.row % sizePattern.count
        return sizePattern[index]
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        let collectionLayout = MosaicFlowLayout()
        collectionLayout.delegate = self
        return collectionLayout
    }
    
    func shouldPaginate() -> Bool {
        return false
    }
    
    // MARK: - MosaicFlowLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.sizeofContent(atIndexPath: indexPath, collectionView: collectionView)
    }
}
