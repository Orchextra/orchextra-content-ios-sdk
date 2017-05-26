//
//  ContentNavigationBarStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentNavigationBarStyles {
    
    /**
     Set the the type of controls displayed for navigation on Content Detail.
     
     - **button**: Buttons for navigation.
     - **navigationBar**: Navigation bar on top for navigation.
     */
    public var type: NavigationType
    
    /**
     Background image for the Content Detail navigation bar.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
    */
    public var barBackgroundImage: UIImage?
    
    /**
     Background image for the Content Detail navigation buttons.
     
     If not set, the navigation button background will use the `Styles.primaryColor`
     */
    public var buttonBackgroundImage: UIImage?
    
    /**
     Enables wheather the Content's name is displayed or not on the navigation bar as a title.
     
     Defaults to `false`.
     */
    public var showTitle: Bool
    
    /**
     Tint color for the Content Detail navigation bar.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
     */
    public var barTintColor: UIColor? // !!!

    /**
     Background image for the Content Detail navigation bar.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
     */
    public var barBackgroundColor: UIColor? //!!!

    /**
     Tint color for the Content Detail navigation buttons.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
     */
    public var buttonTintColor: UIColor? //!!!

    /**
     Background color for the Content Detail navigation buttons.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
     */
    public var buttonBackgroundColor: UIColor? //!!!
    
    // MARK: - Initializer
    
    public init() {
        self.type = .button
        self.showTitle = true
    }

}
