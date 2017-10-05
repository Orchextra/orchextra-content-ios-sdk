//
//  VimeoPresenterPresenter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol VimeoUI: class {
    
}

struct VimeoPresenter {
    
    // MARK: - Public attributes
    
    weak var view: VimeoUI?
    let wireframe: VimeoWireframe
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        
    }
}
