//
//  CardComponent.swift
//  OCM
//
//  Created by José Estela on 24/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

enum CardComponentType {
    case image(url: URL)
    case text(text: String)
}

struct CardComponent {
    let type: CardComponentType
    let percentage: Float
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
        guard
            let imageUrl = card.render["imageUrl"]?.toString(),
            let text = card.render["text"]?.toString(),
            let ratios = card.render["ratios"]?.toArray() as? [Float],
            let image = URL(string: imageUrl)
            else {
                return nil
        }
        if ratios.count == 2 {
            cardComponents.append(CardComponent(type: .image(url: image), percentage: ratios[0]))
            cardComponents.append(CardComponent(type: .text(text: text), percentage: ratios[1]))
        }
        return cardComponents
    }
    
    
    static func loadTextImageCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard
            let imageUrl = card.render["imageUrl"]?.toString(),
            let text = card.render["text"]?.toString(),
            let ratios = card.render["ratios"]?.toArray() as? [Float],
            let image = URL(string: imageUrl)
        else {
            return nil
        }
        if ratios.count == 2 {
            cardComponents.append(CardComponent(type: .text(text: text), percentage: ratios[0]))
            cardComponents.append(CardComponent(type: .image(url: image), percentage: ratios[1]))
        }
        return cardComponents
    }
    
    static func loadRichTextCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard
            let richText = card.render["richText"]?.toString()
        else {
            return nil
        }
        cardComponents.append(CardComponent(type: .text(text: richText), percentage: 1.0))
        return cardComponents
    }
    
    static func loadImageCardComponents(with card: Card) -> [CardComponent]? {
        var cardComponents: [CardComponent] = []
        guard
            let imageUrl = card.render["imageUrl"]?.toString(),
            let image = URL(string: imageUrl)
        else {
            return nil
        }
        cardComponents.append(CardComponent(type: .image(url: image), percentage: 1.0))
        return cardComponents
    }
}
