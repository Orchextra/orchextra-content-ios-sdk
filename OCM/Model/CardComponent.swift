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
        switch card.type {
        case "imageText":
            return loadImageTextCardComponents(with: card)
        case "textImage":
            return loadTextImageCardComponents(with: card)
        case "richText":
            return loadRichTextCardComponents(with: card)
        case "image":
            return loadImageCardComponents(with: card)
        default:
            return nil
        }
    }
    
    // MARK: - Type card methods
    
    static func loadImageTextCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard let ratios = card.render["ratios"]?.toArray() as? [Float] else { return nil }
        
        if ratios.count == 2 {
            if let cardComponentImage = parseImageComponent(with: card, ratio: ratios[0]) {
                cardComponents.append(cardComponentImage)
            }
            
            if let cardComponentText = parseText(with: card, ratio: ratios[1]) {
                cardComponents.append(cardComponentText)
            }
        }
        return cardComponents
    }
    
    static func loadTextImageCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard let ratios = card.render["ratios"]?.toArray() as? [Float] else { return nil }
        
        if ratios.count == 2 {
            if let cardComponentText = parseText(with: card, ratio: ratios[0]) {
                cardComponents.append(cardComponentText)
            }
            
            if let cardComponentImage = parseImageComponent(with: card, ratio: ratios[1]) {
                cardComponents.append(cardComponentImage)
            }
        }
        return cardComponents
    }
    
    static func loadRichTextCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard let richText = card.render["richText"]?.toString() else { return nil }
        let textMargins = CardComponentMargins(top: 92, left: 23.0, right: 23.0, bottom: 0.0)
        cardComponents.append(CardComponentText(text: richText, percentage: 1.0, margins: textMargins))
        return cardComponents
    }
    
    static func loadImageCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        if  let imageCardComponents = parseImageComponent(with: card, ratio: 1.0) {
            cardComponents.append(imageCardComponents)
        }
        return cardComponents
    }
    
    // MARK: - Card Component Parser
    
    static func parseImageComponent(with card: Card, ratio: Float) -> CardComponent? {
        guard
            let imageUrl = card.render["imageUrl"]?.toString(),
            let image = URL(string: imageUrl)
            else {
                return nil
        }
        
        let imageMargins = CardComponentMargins(top: 0.0, left: 0.0, right: 0.0, bottom: 0.0)
        return CardComponentImage(imageUrl: image, percentage: ratio, margins: imageMargins)
    }
    
    static func parseText(with card: Card, ratio: Float) -> CardComponent? {
        guard let text = card.render["text"]?.toString() else { return nil }
        
        let textMargins = CardComponentMargins(top: 92, left: 23.0, right: 23.0, bottom: 0.0)
        return CardComponentText(text: text, percentage: ratio, margins: textMargins)
    }
    
}
