//
//  ActionContent.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct ActionContent: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?

	let path: String
	
    init(preview: Preview?, shareInfo: ShareInfo?, path: String, actionView: OrchextraViewController? =  nil) {
        self.preview = preview
        self.shareInfo = shareInfo
        self.path = path
        self.actionView = actionView
    }
    
	static func action(from json: JSON) -> Action? {
		guard json["type"]?.toString() == ActionType.actionContent,
		let path = json["render.contentUrl"]?.toString()
            else { return nil }
		
        return ActionContent(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            path: path,
            actionView: OCM.shared.wireframe.contentList(from: path)
        )
	}
}
