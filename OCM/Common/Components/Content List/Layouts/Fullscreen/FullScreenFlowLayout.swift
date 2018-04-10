//
//  FullScreenFlowLayout.swift
//  OCM
//
//  Created by José Estela on 19/3/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class FullScreenFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    private func configure() {
        self.scrollDirection = .vertical
        self.minimumLineSpacing = 0
    }
}
