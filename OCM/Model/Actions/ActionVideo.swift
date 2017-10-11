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
    
    var output: ActionOut?
    internal var identifier: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    
    let video: Video
    
    init(video: Video, preview: Preview?, shareInfo: ShareInfo?) {
        self.video = video
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionVideo
            else { return nil }
        
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
                shareInfo: shareInfo(from: json)
            )
            
        }
        return nil
    }
    
    func view() -> OrchextraViewController? {
        if self.actionView == nil {
            switch self.video.format {
            case .youtube:
                self.actionView = OCM.shared.wireframe.showYoutubeVC(videoId: self.video.source)
            default:
                self.actionView = OCM.shared.wireframe.showVideoPlayerVC(with: self.video)
            }
        }
        return self.actionView
    }
    
    func executable() {
        guard let viewController = self.view() else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }
    
    func run(viewController: UIViewController?) {
        if self.preview != nil {
            guard let viewController = viewController else { return }
            OCM.shared.wireframe.showMainComponent(with: self, viewController: viewController)
        } else {
            guard let viewController = self.view() else { return }
            OCM.shared.wireframe.show(viewController: viewController)
        }
    }
}
