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
    var viewController: OrchextraViewController?
    
    init(view: UIView, viewController: OrchextraViewController? = nil) {
        self.view = view
        self.viewController = viewController
    }
}
