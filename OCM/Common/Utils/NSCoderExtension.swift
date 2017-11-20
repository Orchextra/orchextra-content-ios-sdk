//
//  NSCoderExtension.swift
//  OCM
//
//  Created by José Estela on 16/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

extension NSCoder {
    func decode<T>(for key: String, default defaultValue: T) -> T {
        guard let obj = self.decodeObject(forKey: key) as? T else {
            return defaultValue
        }
        
        return obj
    }
    
    func decode<T>(for key: String) -> T? {
        guard let obj = self.decodeObject(forKey: key) as? T else {
            return nil
        }
        
        return obj
    }
}
