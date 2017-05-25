//
//  Styles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class Styles {
    // TODO: Document !!!
    var primaryColor: UIColor = .blue
    // TODO: Document !!!
    var secondaryColor: UIColor = .white
    // TODO: Document !!!
    var placeholderImage: UIImage?
    
    // MARK: - Initializer
    
    public convenience init(primaryColor: UIColor?, secondaryColor: UIColor?, placeholderImage: UIImage?) {
        self.init()
        self.primaryColor = primaryColor ?? self.primaryColor
        self.secondaryColor = secondaryColor ?? self.secondaryColor
        self.placeholderImage = placeholderImage
    }
    
}
