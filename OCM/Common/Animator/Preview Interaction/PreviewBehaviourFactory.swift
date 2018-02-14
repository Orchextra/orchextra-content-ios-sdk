//
//  PreviewInteractionController.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol Behaviour: class {
    func previewDidAppear()
    init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?)
    func performAction(with info: Any?)
}

enum BehaviourType {
    case tap
    case swipe
    
    static func behaviour(fromJson json: JSON) -> BehaviourType? {
        guard let behaviourString = json["behaviour"]?.toString() else { return nil }
        switch behaviourString {
        case "click":
            return .tap
        case "swipe":
            return .swipe
        default:
            return nil
        }
    }
}

struct PreviewBehaviourFactory {
    
    // MARK: - Init
    
    static func behaviour(with scroll: UIScrollView, previewView: UIView, preview: Preview, content: OrchextraViewController?) -> Behaviour? {
        switch preview.behaviour {
        case .some(.tap):
            return Tap(scroll: scroll, previewView: previewView, content: content)
        case .some(.swipe):
            return Swipe(scroll: scroll, previewView: previewView, content: content)
        default:
            return nil
        }
    }
}
