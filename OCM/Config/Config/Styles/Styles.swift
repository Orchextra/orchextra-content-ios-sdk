//
//  Styles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

/// Default style propeties for customizing UI controls and other components.
public class Styles {
    
    /**
     Sets the default color for the following style properties of UI controls:
     
     - Navigation buttons background color.
     - Navigation bar background color.
     - Page control's active page indicator.
     */
    public var primaryColor: UIColor
    
    /**
     Sets the default color for the following style properties of UI controls:
     
     - Navigation buttons tint color.
     - Navigation bar tint color.
     - Page control's inactive page indicator.
     */
    public var secondaryColor: UIColor
    
    /**
     Placeholder image to display as an asynchronous image is being loaded .
     */
    public var placeholderImage: UIImage?
    
    // MARK: - Initializer
    
    public init() {
        self.primaryColor = UIColor(fromRed: 119, green: 119, blue: 119)
        self.secondaryColor = .white
    }
}

public class Palette {
    
    
    
}
