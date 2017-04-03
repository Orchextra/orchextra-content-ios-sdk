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
    
    let type: String
    let render: JSON

    static func card(from json: JSON) -> Card? {
        guard
            let type = json["type"]?.toString(),
            let render = json["render"]
        else {
            return nil
        }
        return Card(type: type, render: render)
    }
}
