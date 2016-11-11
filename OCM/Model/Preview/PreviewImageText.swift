//
//  PreviewImageAndText.swift
//  OCM
//
//  Created by Sergio López on 11/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct PreviewImageText: Preview {
    
    let behaviour: BehaviourType?
    let text: String?
    let imageUrl: String?
    
    static func parsePreview(json: JSON) -> Preview? {
        
        let behaviour = BehaviourType.behaviour(fromJson: json)
        
        guard let imageUrl = json["imageUrl"]?.toString() else {
            LogWarn("preview has not image in json")
            return nil
        }
        
        let text = json["text"]?.toString()
        return PreviewImageText(behaviour: behaviour, text: text, imageUrl: imageUrl)
    }
    
    
    func display() -> UIView? {
        
        guard let previewView = PreviewImageTextView.instantiate() else { return UIView() }
        previewView.load(preview: self)
        
        addConstraints(view: previewView)
        return previewView
    }
    
    // MARK: Helper
    
    func addConstraints(view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Hconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: UIScreen.main.bounds.width
        )
        
        let Vconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: UIScreen.main.bounds.height
        )
        
        view.addConstraints([Hconstraint, Vconstraint])
    }
}
