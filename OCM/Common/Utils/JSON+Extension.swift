//
//  JSON+Extension.swift
//  OCM
//
//  Created by José Estela on 9/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

extension JSON {
    
    func stringRepresentation() -> String {
        return self.description.replacingOccurrences(of: "\\/", with: "/")
    }
    
    static func fromString(_ string: String) -> JSON? {
        if let data = string.data(using: .utf8) {
            return try? JSON.dataToJson(data)
        }
        return nil
    }
}
