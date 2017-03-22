//
//  CardsPresenter.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol CardsUI: class {
    func showElemenst(elements: [Element])
}

struct  CardsPresenter {
    
    // MARK: - Public attributes
    
    weak var view: CardsUI?
    let elements: [Element]
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        // TODO: Get Card model to show it
    }
    
    func viewDidAppear() {
        self.view?.showElemenst(elements: self.elements)
    }
}
