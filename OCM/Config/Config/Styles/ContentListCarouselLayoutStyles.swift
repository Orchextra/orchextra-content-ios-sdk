//
//  ContentListCarouselLayoutStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentListCarouselLayoutStyles {
    // TODO: Document !!!
    var autoPlay: Bool = false
    // TODO: Document !!!
    var autoPlayDuration: Float = 3.0
    // TODO: Document !!!
    var pageControlOffset: CGFloat = 0.0
    // TODO: Document !!!
    // Maybe add this ones? If not defined, then use Styles colors >>>
    var activePageIndicatorColor: UIColor?// = Config.primaryColor
    // TODO: Document !!!
    var inactivePageIndicatorColor: UIColor?// = Config.secondaryColor.withAlphaComponent(0.5)
    
    // MARK: - Initializer
    
    public convenience init(autoPlay: Bool?, autoPlayDuration: Float?, pageControlOffset: CGFloat?, activePageIndicatorColor: UIColor?, inactivePageIndicatorColor: UIColor?) {
        self.init()
        self.autoPlay = autoPlay ?? self.autoPlay
        self.autoPlayDuration = autoPlayDuration ?? self.autoPlayDuration
        self.pageControlOffset = pageControlOffset ?? self.pageControlOffset
        self.activePageIndicatorColor = activePageIndicatorColor
        self.inactivePageIndicatorColor = inactivePageIndicatorColor
    }
    
}
