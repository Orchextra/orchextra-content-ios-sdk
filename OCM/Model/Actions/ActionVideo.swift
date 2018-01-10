//
//  ActionVideo.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class ActionVideo: Action {
    
    var typeAction: ActionEnumType
    var requiredAuth: String? //!!!
    //var segmentation: [String: Any]? //!!!
    var elementUrl: String?
    var output: ActionOut?
    let video: Video
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    
    init(video: Video, preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.video = video
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
        self.type = ActionType.actionVideo
        self.typeAction = ActionEnumType.actionVideo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionVideo
            else { return nil }
        let slug = json["slug"]?.toString()
        if let render = json["render"] {
            
            guard
                let format = render["format"],
                let formatString = format.toString(),
                let source = render["source"],
                let sourceString = source.toString(),
                let formatValue = VideoFormat.from(formatString)
            else {
                return nil
                
            }
            
            return ActionVideo(
                video: Video(source: sourceString, format: formatValue),
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                slug: slug
            )
        }
        return nil
    }
}
