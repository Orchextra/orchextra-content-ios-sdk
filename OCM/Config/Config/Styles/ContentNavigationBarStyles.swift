//
//  ContentNavigationBarStyles.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public class ContentNavigationBarStyles {
    // TODO: Document !!!
    var type: NavigationType = .button
    // TODO: Document !!!
    var barBackgroundImage: UIImage?
    // TODO: Document !!!
    var buttonBackgroundImage: UIImage?
    // TODO: Document !!!
    var showTitle: Bool = true
    // Maybe add this ones? If not defined, then use Styles colors >>>
    // TODO: Document !!!
    var barTintColor: UIColor? //=
    // TODO: Document !!!
    var barBackgroundColor: UIColor? //=
    // TODO: Document !!!
    var buttonTintColor: UIColor? // =
    // TODO: Document !!!
    var buttonBackgroundColor: UIColor? // =
    
    // MARK: - Initializer
    
    public convenience init(type: NavigationType?, barBackgroundImage: UIImage?, buttonBackgroundImage: UIImage?, showTitle: Bool?, barTintColor: UIColor?, barBackgroundColor: UIColor?, buttonTintColor: UIColor?, buttonBackgroundColor: UIColor?) {
        self.init()
        self.type = type ?? self.type
        self.barBackgroundImage = barBackgroundImage
        self.buttonBackgroundImage = buttonBackgroundImage
        self.showTitle = showTitle ?? self.showTitle
        self.barTintColor = barTintColor
        self.barBackgroundColor = barBackgroundColor
        self.buttonTintColor = buttonTintColor
        self.buttonBackgroundColor = buttonBackgroundColor
    }

}
