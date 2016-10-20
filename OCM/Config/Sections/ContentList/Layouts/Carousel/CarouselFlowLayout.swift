//
//  CarouselFlowLayout.swift
//  OCM
//
//  Created by Sergio López on 10/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    private func configure() {
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
    }
}
