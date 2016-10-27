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


class ContentListPresenter {
	
	let path: String
	let view: ContentListView
    var contents = [Content]()
	let contentListInteractor: ContentListInteractor
    var currentFilterTag: String?
    
    // MARK: - Init
    
    init(path: String, view: ContentListView, contentListInteractor: ContentListInteractor) {
        self.path = path
        self.view = view
        self.contentListInteractor = contentListInteractor
    }
    
    // MARK: - View Life Cycle
    
	func viewDidLoad() {
		self.contentListInteractor.contentList(from: self.path) { result in
			switch result {
			case .success(let contentList):
                self.view.layout(contentList.layout)
                self.contents = contentList.contents
                
                var contentToShow = self.contents
                
                if let tag = self.currentFilterTag {
                    contentToShow = self.contents.filter(byTag: tag)
                }
                
				self.view.showContents(contentToShow)
                
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
	
    func userDidFilter(byTag tag: String?) {
        
        self.currentFilterTag = tag
        
        if let tag = tag {
            let filteredContent = self.contents.filter(byTag: tag)
            self.view.showContents(filteredContent)
        } else {
            self.view.showContents(self.contents)
        }
    }
    
	func applicationDidBecomeActive() {
		self.viewDidLoad()
	}
}
