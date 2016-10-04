//
//  ContentListPresenter.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


protocol ContentListView {
	
	func showEmptyError()
	func showContents(_ contents: [Content])
	func getWidth() -> Int
}


class ContentListPresenter {
	
	fileprivate var view: ContentListView
	fileprivate lazy var contentListInteractor = ContentListInteractor(
		service: ContentListService(),
		storage: Storage.shared
	)
	
	
	init(view: ContentListView) {
		self.view = view
	}
	
	func viewDidLoad() {
		self.contentListInteractor.contentList(maxWidth: self.view.getWidth(), minWidth: self.view.getWidth() / 2) { result in
			switch result {
			case .success(let contents):
				self.view.showContents(contents)
				
			case .empty:
				LogInfo("Empty")
				self.view.showEmptyError()
				
			case .error:
				LogInfo("Error")
			}
		}
	}
	
	func userDidSelectContent(_ content: Content) {
		content.action?.run()
	}
	
	func applicationDidBecomeActive() {
		self.viewDidLoad()
	}
	
}
