//
//  VimeoVCVC.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class VimeoVC: UIViewController, VimeoUI {
    
    // MARK: - Attributtes
    
    var presenter: VimeoPresenter?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
    }
}

extension VimeoVC: Instantiable {
    
    // MARK: - Instantiable
    
    public static func storyboard() -> String {
        return ""
    }
    
    public static func identifier() -> String? {
        return "VimeoVC"
    }
}
