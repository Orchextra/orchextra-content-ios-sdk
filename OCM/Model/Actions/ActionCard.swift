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
    
    let cards: [Card]
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    
    static func action(from json: JSON) -> Action? {
        guard
            json["type"]?.toString() == ActionType.actionCard,
            let render = json["render"]?.toDictionary(),
            let renderElements = render["elements"] as? [NSDictionary]
            else {
                return nil
        }
        var cards: [Card] = []
        for element in renderElements {
            if let elements = element["elements"] as? [NSDictionary] {
                if let card = Card.card(from: JSON(from: elements)) {
                    cards.append(card)
                }
            }
        }
        return ActionCard(
            cards: cards,
            id: nil,
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            actionView: OCM.shared.wireframe.showCards(cards)
        )
    }
    
    func run(viewController: UIViewController?) {
        guard let fromVC = viewController else {
            return
        }
        OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
    }
}
