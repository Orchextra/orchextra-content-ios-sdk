//
//  Card.swift
//  OCM
//
//  Created by José Estela on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import UIKit

struct Card {
    let elements: [NSDictionary]

    static func card(from json: JSON) -> Card? {
        guard  let elements = json.toArray() as? [NSDictionary] else { return nil }
        return Card(elements: elements)
    }
}
