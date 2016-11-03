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
    
    let behaviour: BehaviourType
    let text: String?
    let imageUrl: String?
    
    static func parsePreview(json: JSON) -> Preview? {
        
        let behaviour = BehaviourType.behaviour(fromJson: json)
        
        guard   let text = json["text"]?.toString(),
            let imageUrl = json["imageUrl"]?.toString() else { return nil}
        
        return Preview(behaviour: behaviour, text: text, imageUrl: imageUrl)
    }
    
    
    func display() -> UIView? {
        
        guard let urlString = imageUrl else {
            print("There is not preview")
            return nil
        }
        
        let imageView = UIImageView()
        imageView.imageFromURL(urlString: urlString, placeholder: Config.placeholder)
        
        var view = UIView(frame: UIScreen.main.bounds)
        view.addSubviewWithAutolayout(imageView)
        view = addConstraints(view: view)
        return view
    }
    
    // MARK: Helper
    
    func addConstraints(view: UIView) -> UIView {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        let Vconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.height)
        
        view.addConstraints([Hconstraint, Vconstraint])
        return view
    }
    
}
