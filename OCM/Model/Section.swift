//
//  Section.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit


var viewCount = 0

public struct Section {
	public let name: String
	public let action: String
	
	public func openAction() -> UIViewController? {
		let view = UIViewController()
		var viewColor: UIColor
		
		switch viewCount {
		case 0:
			viewColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
			
		case 1:
			viewColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
			
		case 2:
			viewColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
			
		case 3:
			viewColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
			
		default:
			viewColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
			viewCount = -1
		}
		viewCount += 1
		
		view.view.backgroundColor = viewColor
		
		return view
	}
}
