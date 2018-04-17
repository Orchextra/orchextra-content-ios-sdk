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
     Placeholder image to display as an asynchronous image is being loaded in content cell.
     */
    public var placeholderImage: UIImage?
    
    /**
     Background image for the navigation transition from the Content List to a Content Detail.
     
     If not defined, the transition will use the `Styles.secondaryColor` property
     */
    public var transitionBackgroundImage: UIImage?
    
    /**
     Offset for refresh spinner on Content List.
     
     Defaults to `0`
     */
    public var refreshSpinnerOffset: CGFloat
    
    /**
     Offset for new contents available view on Content List.
     
     Defaults to `0`
     */
    public var newContentsAvailableViewOffset: CGFloat
    
    // MARK: - Initializer
    
    public init() {
        self.backgroundColor = .white
        self.cellMarginsColor = .groupTableViewBackground
        self.refreshSpinnerOffset = 0
        self.newContentsAvailableViewOffset = 0
    }
}
