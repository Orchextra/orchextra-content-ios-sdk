//
//  Preview.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct Preview {
    
    let behaviour: String?
    let text: String?
    let imageUrl: String?
    
    static func parsePreview(json: JSON) -> Preview? {
        
        guard   let behaviour = json["behaviour"]?.toString(),
            let text = json["text"]?.toString(),
            let imageUrl = json["imageUrl"]?.toString() else { return nil}
        
        return Preview(behaviour: behaviour, text: text, imageUrl: imageUrl)
    }
    
}
