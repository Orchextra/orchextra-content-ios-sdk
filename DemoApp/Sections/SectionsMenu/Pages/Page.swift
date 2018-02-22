//
//  Page.swift
//  WOAH
//
//  Created by Sergio López on 27/10/16.
//  Copyright © 2016 Gigigo Mobile Services S.L. All rights reserved.
//

import UIKit
import OCMSDK

class Page {
    let view: UIView
    var viewController: UIViewController?
    
    init(view: UIView, viewController: UIViewController? = nil) {
        self.view = view
        self.viewController = viewController
    }
}
