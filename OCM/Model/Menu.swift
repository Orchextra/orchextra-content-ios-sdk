//
//  MenuList.swift
//  OCM
//
//  Created by Judith Medina on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import GIGLibrary

public struct Menu: Equatable {

    public let slug: String
    public let sections: [Section]
    
    // MARK: - Factory methods
    
    static public func menuList(_ json: JSON) throws -> Menu {
        guard
            let slug = json["slug"]?.toString(),
            let elements = json["elements"] else { LogWarn("elements array not found"); throw ParseError.json }
        
        let sections = elements.compactMap(Section.parseSection)
        return Menu(slug: slug, sections: sections)
    }
    
    public static func == (lhs: Menu, rhs: Menu) -> Bool {
        return lhs.sections == rhs.sections
    }
}
