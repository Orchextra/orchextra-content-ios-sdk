//
//  ActionYoutube.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class ActionYoutube: Action {
    
    internal var identifier: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    lazy internal var actionView: OrchextraViewController? = OCM.shared.wireframe.showYoutubeVC(videoId: self.source)

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
            
            return ActionYoutube(
                source: sourceString,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json)
            )

        }
        
        return nil
    }
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
    func executable() {
        guard let viewController = self.view() else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }
    
    func run(viewController: UIViewController?) {
        if self.preview != nil {
            guard let viewController = viewController else { return }
            print(viewController)
            OCM.shared.wireframe.showMainComponent(with: self, viewController: viewController)
        } else {
            guard let viewController = self.view() else { return }
            print(viewController)
            OCM.shared.wireframe.show(viewController: viewController)
        }
    }

}
