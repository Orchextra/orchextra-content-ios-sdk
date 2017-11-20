//
//  JSONHelper.swift
//  OCMTests
//
//  Created by José Estela on 16/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

extension JSON {
    
    static func from(file path: String) -> JSON {
        let file = Bundle(for: ContentCoreDataPersisterTests.self).url(forResource: path, withExtension: "json")!
        let data = try! Data(contentsOf: file)
        let json = try! JSON.dataToJson(data)
        return json
    }
}
