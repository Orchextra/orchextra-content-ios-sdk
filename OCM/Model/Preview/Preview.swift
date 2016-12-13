//
//  Preview.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol Preview {
    
    var behaviour: BehaviourType? {get}
    
    static func parsePreview(json: JSON) -> Preview?
    func display() -> PreviewView?
    func imagePreview() -> UIImageView?
}
