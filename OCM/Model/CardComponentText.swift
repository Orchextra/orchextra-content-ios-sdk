//
//  CardComponentText.swift
//  OCM
//
//  Created by Carlos Vicente on 27/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct CardComponentText: CardComponent {
    var text: String
    var percentage: Float
    var margins: CardComponentMargins
    var viewer: CardComponentViewer {
        return CardComponentTextViewer(cardComponent: self)
    }
}
