//
//  PreviewInteractionController.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


protocol Behaviour {
    init(scroll: UIScrollView, previewView: UIView, existContentBelow: Bool, completion:  @escaping () -> Void)
}

enum BehaviourType {
    case tap
    case swipe
    
    static func behaviour(fromJson json: JSON) -> BehaviourType {
        guard let behaviourString = json["behaviour"]?.toString() else { return .tap }
        switch behaviourString {
        case "tap":
            return .tap
        case "swipe":
            return .swipe
        default:
            return .tap
        }
    }
}

struct PreviewInteractionController {
    
    private let behaviour: Behaviour
    
    // MARK: - Init
    
    init(scroll: UIScrollView, previewView: UIView, preview: Preview, existContentBelow: Bool, interactionCompletion: @escaping () -> Void) {
        
        switch preview.behaviour {
        case .tap:
            self.behaviour = Tap(scroll: scroll, previewView: previewView, existContentBelow: existContentBelow, completion: interactionCompletion)
        case .swipe:
            self.behaviour = Swipe(scroll: scroll, previewView: previewView, existContentBelow: existContentBelow, completion: interactionCompletion)
        }
    }
}
