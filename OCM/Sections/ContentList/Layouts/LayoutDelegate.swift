//
//  LayoutDelegate.swift
//  OCM
//
//  Created by Sergio López on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol LayoutDelegate {
    
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize
    func shouldShowPageController() -> Bool
    func shouldPaginate() -> Bool
    func collectionViewLayout() -> UICollectionViewLayout
}
