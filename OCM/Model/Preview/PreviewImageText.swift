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
    let shareInfo: ShareInfo?

    static func preview(from json: JSON, shareInfo: ShareInfo?) -> Preview? {
        let behaviour = BehaviourType.behaviour(fromJson: json)
        guard let imageUrl = json["imageUrl"]?.toString() else {
            logWarn("preview has not image in json")
            return nil
        }
        
        let text = json["text"]?.toString()
        return PreviewImageText(behaviour: behaviour, text: text, imageUrl: imageUrl, shareInfo: shareInfo)
    }
    
    func display() -> PreviewView? {
        
        guard let previewView = PreviewImageTextView.instantiate() else { return nil }
        previewView.load(preview: self)
        
        gig_constrain_size(previewView, UIScreen.main.bounds.size)
        return previewView
    }
    
    func imagePreview() -> UIImageView? {
        guard let previewView = PreviewImageTextView.instantiate() else { return nil }
        return previewView.imageView
    }
    
}
