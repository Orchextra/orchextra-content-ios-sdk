//
//  Section.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

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
        
        self.actionInteractor = ActionInteractor(
            contentDataManager: .defaultDataManager()
        )
    }
    
    static public func parseSection(json: JSON) -> Section? {
        guard
            let name			= json["sectionView.text"]?.toString(),
            let slug            = json["slug"]?.toString(),
            let elementUrl      = json["elementUrl"]?.toString(),
            let requiredAuth    = json["segmentation.requiredAuth"]?.toString()
            else { logWarn("Mandatory field not found"); return nil }
        
        return Section(
            name: name,
            slug: slug,
            elementUrl: elementUrl,
            requiredAuth: requiredAuth
        )
        
    }
    
    public func openAction(completion: @escaping (OrchextraViewController?) -> Void) {
        self.actionInteractor.action(with: self.elementUrl) { action, _ in
            if let view = action?.view() {
                completion(view)
            } else {
                action?.run()
                completion(nil)
            }
        }
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
