//
//  ContentListCarouselLayoutStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentListCarouselLayoutStyles {

    /**
     Enables automatic transitions between pages on Content List with carousel layout.
     
     Defaults to `false`
     */
    public var autoPlay: Bool
    
    /**
     Duration of animation for transitions between pages when `autoPlay` is enabled.
     
     Defaults to `3.0 secs`
     */
    public var autoPlayDuration: Float
    
    /**
     Offset for page control on Content List with carousel layout.
     
     Defaults to `0`
     */
    public var pageControlOffset: CGFloat
    
    
    /**
     Sets the color for page control's current page indicator.
     
     If not set, the current page indicator will use `Styles.primaryColor` value
     */
    public var activePageIndicatorColor: UIColor? //!!!

    /**
     Sets the color for page control's inactive page indicator.
     
     If not set, the page indicator will use `Styles.secondaryColor` value with an alpha value of `0.5`
     */
    public var inactivePageIndicatorColor: UIColor? //!!!
    
    // MARK: - Initializer
    
    public init() {
        self.autoPlay = false
        self.autoPlayDuration = 3.0
        self.pageControlOffset =  0.0
    }
    
}
