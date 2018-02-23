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
    
    func numberOfItemsContained(in view: UIView) -> Int {
        let viewHeight = view.frame.height - 20
        let mosaic = MosaicFlowLayout()
        let height = mosaic.sizeForElement(ofGridSize: CGSize(width: 1, height: 1)).height
        var columns = [0, 0, 0]
        var currentRow = 0
        var items = 0
        let auxPatterns = self.sizePattern + self.sizePattern + self.sizePattern
        for size in auxPatterns {
            items += 1
            if size.width == 1 {
                columns[currentRow] += Int(size.height)
                currentRow += 1
            } else if size.width == 2 {
                columns[currentRow] += Int(size.height)
                columns[currentRow + 1] += Int(size.height) // !!! Make it save
                currentRow += 2
            }
            if let maxHeight = columns.map({ height * CGFloat($0) }).sorted(by: { $0 > $1 }).first, maxHeight >= viewHeight && columns.allEqual() {
                break
            }
            if currentRow >= columns.count || columns.allEqual() {
                currentRow = columns.enumerated().sorted(by: { $0.element < $1.element }).first?.offset ?? 0
            }
        }
        return items
    }
    
    // MARK: - MosaicFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.sizeofContent(atIndexPath: indexPath, collectionView: collectionView)
    }
}

private extension Array where Element : Equatable {
    
    func allEqual() -> Bool {
        if let firstElem = first {
            return !dropFirst().contains { $0 != firstElem }
        }
        return true
    }
}
