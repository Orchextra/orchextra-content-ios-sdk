//
//  ContentListStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentListStyles {

    // MARK: - Public properties

    /**
     Background color for Content List. 
     
     Avoids whitespaces form being displayed.
     */
    public var backgroundColor: UIColor
    
    /**
     Margin color for Content List cells.
     */
    public var cellMarginsColor: UIColor
    
    /**
     Background image for the navigation transition from the Content List to a Content Detail.
     
     If not defined, the transition will use the `Styles.secondaryColor` property
     */
    public var transitionBackgroundImage: UIImage?
    
    // MARK: - Initializer
    
    public init() {
        self.backgroundColor = .white
        self.cellMarginsColor = .groupTableViewBackground
    }
}
