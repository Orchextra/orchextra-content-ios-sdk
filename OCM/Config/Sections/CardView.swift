//
//  CardView.swift
//  OCM
//
//  Created by José Estela on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
    // MARK: - Private attributes
    
    fileprivate var cardComponents: [CardComponent] = []
    fileprivate var stackView: UIStackView?
    
    // MARK: - Instance method
    
    class func from(card: Card) -> CardView? {
        let cardView = CardView()
        cardView.stackView = UIStackView()
        cardView.stackView?.axis = .vertical
        cardView.stackView?.alignment = .center
        cardView.stackView?.distribution = .fill
        // Get the card components and add its to view
        guard let components = CardComponentsFactory.cardComponents(with: card) else { return nil }
        cardView.initializeCardView(with: components)
        return cardView
    }
}

private extension CardView {

    func initializeCardView(with components: [CardComponent]) {
        guard let stackView = self.stackView else { return }
        self.backgroundColor = .white
        self.addSubViewWithAutoLayout(
            view: stackView,
            withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0)
        )
        
        for component in components {
            let componentView = component.viewer.displayView()
            self.stackView?.addArrangedSubview(componentView)
        }
    }
}
