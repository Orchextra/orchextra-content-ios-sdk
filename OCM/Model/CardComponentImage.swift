//
//  CardComponentImage.swift
//  OCM
//
//  Created by Carlos Vicente on 27/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct CardComponentImage: CardComponent {
    var imageUrl: URL
    var percentage: Float
    var margins: CardComponentMargins
    var viewer: CardComponentViewer {
        return CardComponentImageViewer(cardComponent: self)
    }
}
