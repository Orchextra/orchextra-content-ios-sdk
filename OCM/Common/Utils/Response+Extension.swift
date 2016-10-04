//
//  Request+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 1/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum ResponseError: Error {
    case bodyNil
}

extension Response {
    
    func json() throws -> JSON {
        guard let json = self.body else {
            throw ResponseError.bodyNil
        }
        
        return JSON(from: json)
    }
	
	func image() throws -> UIImage {
		guard let image = self.body as? UIImage else {
			throw ResponseError.bodyNil
		}
		
		return image
	}
    
}
