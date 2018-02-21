//
//  SearchPresenter.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

protocol SearchUI: class {
    
}

struct  SearchPresenter {
    
    // MARK: - Public attributes
    
    weak var view: SearchUI?
    let wireframe: SearchWireframeInput
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        
    }
}
