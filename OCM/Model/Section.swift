//
//  Section.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

var viewCount = 0

public struct Section: Equatable {
    public let name: String
    public let slug: String
    public let elementUrl: String
    public let requiredAuth: String
    
    
    private let actionInteractor: ActionInteractor
    
    init(name: String, slug: String, elementUrl: String, requiredAuth: String) {
        self.name = name
        self.elementUrl = elementUrl
        self.slug = slug
        self.requiredAuth = requiredAuth
        
        self.actionInteractor = ActionInteractor(dataManager: ActionDataManager(storage: Storage.shared))
    }
    
    static public func parseSection(json: JSON) -> Section? {
        guard
            let name			= json["sectionView.text"]?.toString(),
            let slug            = json["slug"]?.toString(),
            let elementUrl      = json["elementUrl"]?.toString(),
            let requiredAuth    = json["segmentation.requiredAuth"]?.toString()
            else { LogWarn("Mandatory field not found"); return nil }
        
        return Section(
            name: name,
            slug: slug,
            elementUrl: elementUrl,
            requiredAuth: requiredAuth
        )
        
    }
    
    public func openAction() -> OrchextraViewController? {
        guard let action = self.actionInteractor.action(from: self.elementUrl) else { return nil }
        
        if let view = action.view() {
            return view
        }
        
        action.run()
        return nil
    }
    
    // MARK: Equatable protocol
    
    public static func == (lhs: Section, rhs: Section) -> Bool {
        let nameIsEqual = (lhs.name == rhs.name)
        let slugIsEqual = (lhs.slug == rhs.slug)
        let elementUrlIsEqual = (lhs.elementUrl == rhs.elementUrl)
        let requiredAuthIsEqual = (lhs.requiredAuth == rhs.requiredAuth)
        
        return nameIsEqual &&
            slugIsEqual &&
            elementUrlIsEqual &&
        requiredAuthIsEqual
    }
    
    
}
