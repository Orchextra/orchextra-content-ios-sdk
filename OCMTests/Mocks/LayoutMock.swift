//
//  LayoutMock.swift
//  OCMTests
//
//  Created by José Estela on 22/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit
@testable import OCMSDK

class LayoutMock: Layout {
    
    var type: LayoutType = .mosaic
    
    func sizeofContent(atIndexPath indexPath: IndexPath, collectionView: UICollectionView) -> CGSize {
        return CGSize.zero
    }
    
    func shouldShowPageController() -> Bool {
        return false
    }
    
    func shouldPaginate() -> Bool {
        return false
    }
    
    func shouldAutoPlay() -> Bool {
        return false
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewLayout()
    }
}
