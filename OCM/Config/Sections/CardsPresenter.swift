//
//  CardsPresenter.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol CardsUI: class {
    func showCards(cards: [Card])
}

struct CardsPresenter {
    
    // MARK: - Public attributes
    
    weak var view: CardsUI?
    let cards: [Card]
    
    // MARK: - Input methods
    
    func viewDidLoad() {
    }
    
    func viewDidAppear() {
        self.view?.showCards(cards: self.cards)
    }
}
