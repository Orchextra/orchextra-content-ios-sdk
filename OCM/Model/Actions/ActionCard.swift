//
//  ActionCard.swift
//  OCM
//
//  Created by Carlos Vicente on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ActionCard: Action {
    
    var typeAction: ActionEnumType
    var customProperties: [String: Any]?
    var elementUrl: String?
    var output: ActionOut?
    let cards: [Card]
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var slug: String?
    internal var type: String?

    static func action(from json: JSON) -> Action? {
        guard
            json["type"]?.toString() == ActionType.actionCard,
            let render = json["render"]?.toDictionary(),
            let renderElements = render["elements"] as? [NSDictionary]
            else {
                return nil
        }
        var cards: [Card] = []
        for renderElement in renderElements {
            guard let cardsElements = renderElement["elements"] as? [NSDictionary] else { return nil }
            for card in cardsElements {
                guard let cardComponents = card["elements"] as? [NSDictionary] else { return nil }
                if let card = Card.card(from: JSON(from: cardComponents)) {
                    cards.append(card)
                }
            }
        }
        let slug = json["slug"]?.toString()
        return ActionCard(
            typeAction: ActionEnumType.actionCard,
            customProperties: json["customProperties"]?.toDictionary(),
            elementUrl: nil,
            output: nil,
            cards: cards,
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug,
            type: ActionType.actionCard
        )
    }
}
