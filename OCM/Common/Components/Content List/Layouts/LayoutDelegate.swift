//
//  Layout.swift
//  OCM
//
//  Created by Sergio López on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol Layout {
    var type: LayoutType { get }
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize
    func shouldShowPageController() -> Bool
    func shouldPaginate() -> Bool
    func shouldAutoPlay() -> Bool
    func collectionViewLayout() -> UICollectionViewLayout
    func numberOfItemsToFitLayout() -> Int
}
