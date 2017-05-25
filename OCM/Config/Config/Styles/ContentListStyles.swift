//
//  ContentListStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentListStyles {
    // TODO: Document !!!
    var backgroundColor: UIColor = .white
    // TODO: Document !!!
    var cellMarginsColor: UIColor = .groupTableViewBackground
    // TODO: Document !!!
    var transitionBackgroundImage: UIImage?
    
    // MARK: - Initializer
    
    public convenience init(backgroundColor: UIColor?, cellMarginsColor: UIColor?, transitionBackgroundImage: UIImage?) {
        self.init()
        self.backgroundColor = backgroundColor ?? self.backgroundColor
        self.cellMarginsColor = cellMarginsColor ?? self.cellMarginsColor
        self.transitionBackgroundImage = transitionBackgroundImage
    }
    
}
