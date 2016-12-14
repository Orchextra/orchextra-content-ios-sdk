//
//  ActionYoutube.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ActionYoutube: Action {
    
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?

    let source: String
    
    init(source: String, preview: Preview?, shareInfo: ShareInfo?) {
        self.source = source
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionYoutube
            else { return nil }
        
        if let render = json["render"] {
            
            guard let format = render["format"],
                  let formatString = format.toString(),
                  let source = render["source"],
                  let sourceString = source.toString(), (formatString == "youtube") else { return nil }
            
            return ActionYoutube(source: sourceString, preview: preview(from: json), shareInfo: shareInfo(from: json))

        }
        
        return nil
    }
    
    func view() -> OrchextraViewController? {
        return OCM.shared.wireframe.showYoutubeVC(videoId: source)
    }
    
    func executable() {
        guard let viewController = self.view() else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }
    
    func run(viewController: UIViewController?) {
        
        guard let viewController = self.view() else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }

}
