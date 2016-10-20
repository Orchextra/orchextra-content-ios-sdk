//
//  ContentListPresenter.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit


protocol ContentListView {
    func layout(_ layout: LayoutDelegate)
	func showEmptyError()
	func showContents(_ contents: [Content])
	func getWidth() -> Int
}


struct ContentListPresenter {
	
	let path: String
	let view: ContentListView
	let contentListInteractor: ContentListInteractor
	
	func viewDidLoad() {
		self.contentListInteractor.contentList(from: self.path) { result in
			switch result {
			case .success(let contentList):
                self.view.layout(contentList.layout)
				self.view.showContents(contentList.contents)
				
			case .empty:
				LogInfo("Empty")
				self.view.showEmptyError()
				
			case .error:
				LogInfo("Error")
			}
		}
	}
	
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {
        _ = content.openAction(from: viewController)
	}
	
	func applicationDidBecomeActive() {
		self.viewDidLoad()
	}
}
