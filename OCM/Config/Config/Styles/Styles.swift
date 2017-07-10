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
    
    // MARK: - Initializer
    
    public init() {
        self.primaryColor = .blue
        self.secondaryColor = .white
    }
}

public class Palette {
    
    
    
}
