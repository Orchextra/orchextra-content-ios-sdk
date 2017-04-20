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
    
    // MARK: - Public attributes
    
    var behaviour: BehaviourType? { get }
    var shareInfo: ShareInfo? { get }
    
    // MARK: - Public methods
    
    static func preview(from json: JSON, shareInfo: ShareInfo?) -> Preview?
    
    func display() -> PreviewView?
}
