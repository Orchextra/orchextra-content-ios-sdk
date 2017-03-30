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
    var margins: CardComponentMargins {
        return CardComponentMargins(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0
        )
    }
    var viewer: CardComponentViewer {
        return CardComponentImageViewer(cardComponent: self)
    }
}
