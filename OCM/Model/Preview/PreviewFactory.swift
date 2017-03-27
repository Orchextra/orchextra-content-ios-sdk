//
//  PreviewFactory.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class PreviewFactory {
    
    static func preview(from json: JSON, shareInfo: ShareInfo?) -> Preview? {
        let previews = [
            PreviewImageText.preview(from: json, shareInfo: shareInfo),
            PreviewList.preview(from: json, shareInfo: shareInfo)
        ]
        
        // Returns the last preview that is not nil, or nil if there is no preview available
        return previews.reduce(PreviewImageText.preview(from: json, shareInfo: shareInfo), { $1 ?? $0 })
    }
}
