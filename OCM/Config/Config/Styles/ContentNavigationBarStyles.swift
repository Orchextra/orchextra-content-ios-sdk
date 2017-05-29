//
//  ContentNavigationBarStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentNavigationBarStyles {
    
    // MARK: - Private properties (f/computed properties)
    private var _barTintColor: UIColor?
    private var _barBackgroundColor: UIColor?
    private var _buttonTintColor: UIColor?
    private var _buttonBackgroundColor: UIColor?

    // MARK: - Public properties
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
     
     If not set, the navigation bar tint color will be the `Styles.secondaryColor`
     */
    public var barTintColor: UIColor {
        get {
            return _barTintColor ?? Config.styles.secondaryColor
        }
        set {
            _barTintColor = newValue
        }
    }

    /**
     Background image for the Content Detail navigation bar.
     
     If not set, the navigation bar background will use the `Styles.primaryColor`
     */
    public var barBackgroundColor: UIColor {
        get {
            return _barBackgroundColor ?? Config.styles.primaryColor
        }
        set {
            _barBackgroundColor = newValue
        }
    }

    /**
     Tint color for the Content Detail navigation buttons.
     
     If not set, the navigation button tint color will be the `Styles.secondaryColor`
     */
    public var buttonTintColor: UIColor {
        get {
            return _buttonTintColor ?? Config.styles.secondaryColor
        }
        set {
            _buttonTintColor = newValue
        }
    }

    /**
     Background color for the Content Detail navigation buttons.
     
     If not set, the navigation button background will use the `Styles.primaryColor`
     */
    public var buttonBackgroundColor: UIColor {
        get {
            return _buttonBackgroundColor ?? Config.styles.primaryColor
        }
        set {
            _buttonBackgroundColor = newValue
        }
    }
    
    // MARK: - Initializer
    
    public init() {
        self.type = .button
        self.showTitle = true
    }

}
