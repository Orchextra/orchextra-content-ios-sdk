//
//  MosaicLayout.swift
//  OCM
//
//  Created by Sergio López on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

struct MosaicLayout: Layout, MosaicFlowLayoutDelegate {
    
    let type = LayoutType.mosaic
    
    let sizePattern: [CGSize]
    
    // MARK: - Layout
    
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
    
    func shouldAutoPlay() -> Bool {
        return false
    }
    
    func numberOfItemsToFitLayout() -> Int {
        return 12
    }
    
    // MARK: - MosaicFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.sizeofContent(atIndexPath: indexPath, collectionView: collectionView)
    }
}

private extension Array where Element : Equatable {
    
    func allEquals() -> Bool {
        if let firstElem = first {
            return !dropFirst().contains { $0 != firstElem }
        }
        return true
    }
}
