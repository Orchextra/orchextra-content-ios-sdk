//
//  Storage.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


/// In memory model cache

class Storage {
	
	static let shared = Storage()
	
	var elementsCache: JSON?
	
	func appendElementsCache(elements: JSON?) {
		guard var currentElements = self.elementsCache?.toDictionary() else { return }
		guard let newElements = elements?.toDictionary() else { return }
		
		for (key, value) in newElements {
			currentElements.updateValue(value, forKey: key)
		}
		
		self.elementsCache = JSON(from: currentElements)
	}
    
    func appendElement(with identifier: String, and action: JSON) {
        guard var currentElements = self.elementsCache?.toDictionary() else { return }
        currentElements[identifier] = action.toDictionary()
        self.elementsCache = JSON(from: currentElements)
    }
}
