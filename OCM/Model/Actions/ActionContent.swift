//
//  ActionContent.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


class ActionContent: Action {
    
    internal var identifier: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    lazy internal var actionView: OrchextraViewController? = OCM.shared.wireframe.contentList(from: self.path)

	let path: String
	
    init(preview: Preview?, shareInfo: ShareInfo?, path: String) {
        self.preview = preview
        self.shareInfo = shareInfo
        self.path = path
    }
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
	static func action(from json: JSON) -> Action? {
		guard json["type"]?.toString() == ActionType.actionContent,
		let path = json["render.contentUrl"]?.toString()
            else { return nil }
		
        return ActionContent(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            path: path
        )
	}
}
