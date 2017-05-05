//
//  PreviewList.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol PreviewElement {
    static func previewElement(from json: JSON) -> PreviewElement
    func previewView(behaviour: BehaviourType?, shareInfo: ShareInfo?) -> PreviewView?
}

struct ImageAndTextPreviewElement: PreviewElement {
    let imageUrl: String?
    let text: String?
    
    static func previewElement(from json: JSON) -> PreviewElement {
        let imageUrl = json["imageUrl"]?.toString()
        let text = json["text"]?.toString()
        return ImageAndTextPreviewElement(imageUrl: imageUrl, text: text)
    }
    
    func previewView(behaviour: BehaviourType?, shareInfo: ShareInfo?) -> PreviewView? {
        let previewView = PreviewImageTextView.instantiate()
        let previewImageText = PreviewImageText(
            behaviour: behaviour,
            text: self.text,
            imageUrl: self.imageUrl,
            shareInfo: shareInfo
        )
        previewView?.load(preview: previewImageText)
        
        return previewView
    }
}

struct PreviewElementFactory {

    static func previewElement(from json: JSON) -> PreviewElement? {
        let previewElements = [
            ImageAndTextPreviewElement.previewElement(from: json)
        ]
        
        // Returns the last preview element that is not nil, or nil if there is no preview element available
        return previewElements.reduce(nil, { $1 })
    }
}

struct PreviewList: Preview {
    let list: [PreviewElement]
    
    // MARK: Preview protocol attributes
    let behaviour: BehaviourType?
    let shareInfo: ShareInfo?
    
    // MARK: Preview protocol methods
    static func preview(from json: JSON, shareInfo: ShareInfo?) -> Preview? {
        let behaviour = BehaviourType.behaviour(fromJson: json)
        var previewElements: [PreviewElement] = [PreviewElement]()
        
        guard let renderElementsJson = json["render"]?.toArray() else { return nil }
        
        for render in renderElementsJson {
            let renderJson = JSON(from: render)
            if let previewElement = PreviewElementFactory.previewElement(from: renderJson) {
                previewElements.append(previewElement)
            }
        }
        
        if previewElements.count > 0 {
            return PreviewList(
                list: previewElements,
                behaviour: behaviour,
                shareInfo: shareInfo
            )
        } else {
            return nil
        }
    }
    
    func display() -> PreviewView? {
        guard let previewListView = PreviewListView.instantiate() else { return nil }
        gig_constrain_size(previewListView, UIScreen.main.bounds.size)
        previewListView.load(preview: self)
        return previewListView
    }
    
}
