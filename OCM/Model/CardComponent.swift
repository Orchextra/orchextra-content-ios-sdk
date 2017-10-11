//
//  CardComponent.swift
//  OCM
//
//  Created by José Estela on 24/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol CardComponent {
    var percentage: Float { get }
    var margins: CardComponentMargins { get }
    var viewer: CardComponentViewer { get }
}

struct CardComponentsFactory {
    
    // MARK: - Static method
    
    static func cardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = [CardComponent]()
        let elements = card.elements
        for element in elements {
            if let cardComponent = CardComponentsFactory.parse(cardComponentJson: element) {
                cardComponents.append(cardComponent)
            }
        }
        
        return cardComponents
    }
    
    // MARK: - Parsing methods
    
    static func parse(cardComponentJson: NSDictionary) -> CardComponent? {
        var cardComponent: CardComponent?
        guard let type = cardComponentJson["type"] as? String,
            let renderJson = cardComponentJson["render"] as? NSDictionary else { return nil }
        
        let ratio = cardComponentJson["ratio"] as? Float ?? 1.0
        
        switch type {
        case "richText":
            guard let text = CardComponentsFactory.parseText(for: renderJson) else { return nil }
            cardComponent = CardComponentText(text: text, percentage: ratio)
        case "image":
            guard let imageUrl = CardComponentsFactory.parseImage(for: renderJson) else { return nil }
            cardComponent = CardComponentImage(imageUrl: imageUrl, percentage: ratio)
        default:
            guard let text = CardComponentsFactory.parseText(for: renderJson) else { return nil }
            cardComponent = CardComponentText(text: text, percentage: ratio)
        }
        return cardComponent
    }
    
    // MARK: - Card Component Parser
    
    static func parseImage(for cardComponentJson: NSDictionary) -> URL? {
        guard
            let imageUrl = cardComponentJson["imageUrl"] as? String,
            let image = URL(string: imageUrl)
            else {
                return nil
        }
        
        return image
    }
    
    static func parseText(for cardComponentJson: NSDictionary) -> String? {
        guard let text = cardComponentJson["html"] as? String else { return nil }
        return text
    }
    
}
