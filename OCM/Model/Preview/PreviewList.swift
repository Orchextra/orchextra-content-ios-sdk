//
//  PreviewList.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum PreviewElementType {
    case imageAndText
}

struct PreviewElement {
    let imageUrl: String?
    let text: String?
    let type: PreviewElementType
    
    static func previewElement(from json: JSON) -> PreviewElement {
        let imageUrl = json["imageUrl"]?.toString()
        let text = json["text"]?.toString()
        let type = json["type"]?.toString()
        let typeTranslated = PreviewElement.previewType(from: type)
        return PreviewElement(imageUrl: imageUrl, text: text, type: typeTranslated)
    }
    
    static func previewType(from typeString: String?) -> PreviewElementType {
        var previewType: PreviewElementType = .imageAndText
        
        if let typeStringNotNil =  typeString {
            switch typeStringNotNil {
            case "imageAndText":
                previewType = .imageAndText
            default:
                previewType = .imageAndText
            }
        }
        return previewType
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
                let previewElement = PreviewElement.previewElement(from: renderJson)
                previewElements.append(previewElement)
        }
        
        return PreviewList(
            list: previewElements,
            behaviour: behaviour,
            shareInfo: shareInfo
        ) 
    }
    
    func display() -> PreviewView? {
        return nil
    }
}
