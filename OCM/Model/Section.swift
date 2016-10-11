//
//  Section.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit


public struct Section {
	public let name: String
	public let action: String
	
	public func openAction() -> UIViewController? {
		return UIViewController()
	}
}
