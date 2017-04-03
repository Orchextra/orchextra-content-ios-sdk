//
//  CardComponentText.swift
//  OCM
//
//  Created by Carlos Vicente on 27/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct MarginConstants {
    static let top: Float       = 92.0
    static let left: Float      = 23.0
    static let right: Float     = 23.0
    static let bottom: Float    = 0.0
}

struct CardComponentText: CardComponent {
    var text: String
    var percentage: Float
    var margins: CardComponentMargins {
        return CardComponentMargins(
            top: MarginConstants.top,
            left: MarginConstants.left,
            right: MarginConstants.right,
            bottom: MarginConstants.bottom)
    }
    var viewer: CardComponentViewer {
        return CardComponentTextViewer(cardComponent: self)
    }
}
