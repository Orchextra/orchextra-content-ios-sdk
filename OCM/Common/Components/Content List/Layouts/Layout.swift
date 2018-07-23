//
//  Layout.swift
//  OCM
//
//  Created by Sergio López on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

public enum LayoutType {
    case carousel
    case mosaic
    case fullscreen
    
    static func from(string: String) -> LayoutType {
        if string == "carousel" {
            return .carousel
        } else if string == "fullScreen" {
            return .fullscreen
        }
        return .mosaic
    }
}

protocol Layout {
    var type: LayoutType { get }
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize
    func shouldShowPageController() -> Bool
    func shouldPaginate() -> Bool
    func shouldAutoPlay() -> Bool
    func collectionViewLayout() -> UICollectionViewLayout
    func shouldPullToRefresh() -> Bool
}
