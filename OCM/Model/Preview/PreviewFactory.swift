//
//  PreviewFactory.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum PreviewType {
    case simple
    case carousel
    
    static func previewType(from type: String) -> PreviewType {
        var previewType: PreviewType
        switch type {
        case "carousel":
            previewType = .carousel
        default:
            previewType = .simple
        }
        return previewType
    }
}

class PreviewFactory {
    
    static func preview(from json: JSON, shareInfo: ShareInfo?) -> Preview? {
        guard let typeJson = json["type"]?.toString() else { return nil }
        let type = PreviewType.previewType(from: typeJson)
        switch type {
        case .carousel:
            return PreviewList.preview(from: json, shareInfo: shareInfo)
        default:
            return PreviewImageText.preview(from: json, shareInfo: shareInfo)
        }
    }
}
