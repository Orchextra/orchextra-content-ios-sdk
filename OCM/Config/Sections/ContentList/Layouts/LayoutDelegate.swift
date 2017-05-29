//
//  LayoutDelegate.swift
//  OCM
//
//  Created by Sergio López on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

//swiftlint:disable class_delegate_protocol
protocol LayoutDelegate {
    var type: Layout { get }
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize
    func shouldShowPageController() -> Bool
    func shouldPaginate() -> Bool
    func shouldAutoPlay() -> Bool
    func collectionViewLayout() -> UICollectionViewLayout
}
//swiftlint:enable class_delegate_protocol
