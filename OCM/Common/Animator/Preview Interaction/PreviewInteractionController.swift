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
    init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?, completion:  @escaping () -> Void)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    //func contentScrollDidScroll(_ scrollView: UIScrollView)
}

enum BehaviourType {
    case tap
    case swipe
    
    static func behaviour(fromJson json: JSON) -> BehaviourType? {
        guard let behaviourString = json["behaviour"]?.toString() else { return .tap }
        switch behaviourString {
        case "tap":
            return .tap
        case "swipe":
            return .swipe
        default:
            return nil
        }
    }
}

struct PreviewInteractionController {
    
    private let behaviour: Behaviour
    
    // MARK: - Init
    
    static func previewInteractionController(scroll: UIScrollView, previewView: UIView, preview: Preview, content: OrchextraViewController?, interactionCompletion: @escaping () -> Void) -> Behaviour? {
        
        switch preview.behaviour {
        case .some(.tap):
            return Tap(scroll: scroll, previewView: previewView, content: content, completion: interactionCompletion)
        case .some(.swipe):
            return Swipe(scroll: scroll, previewView: previewView, content: content, completion: interactionCompletion)
        default:
            return nil
        }
    }
}
