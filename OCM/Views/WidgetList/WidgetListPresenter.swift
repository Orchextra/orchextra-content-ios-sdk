//
//  WidgetListPresenter.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


protocol WidgetListView {
	
	func showEmptyError()
	func showWidgets(_ widgets: [Widget])
	func getWidth() -> Int
}


class WidgetListPresenter {
	
	fileprivate var view: WidgetListView
	fileprivate lazy var widgetListInteractor = WidgetListInteractor(
		service: WidgetListService(),
		storage: Storage.shared
	)
	
	
	init(view: WidgetListView) {
		self.view = view
	}
	
	func viewDidLoad() {
		self.widgetListInteractor.widgetList(maxWidth: self.view.getWidth(), minWidth: self.view.getWidth() / 2) { result in
			switch result {
			case .success(let widgets):
				self.view.showWidgets(widgets)
				
			case .empty:
				LogInfo("Empty")
				self.view.showEmptyError()
				
			case .error:
				LogInfo("Error")
			}
		}
	}
	
	func userDidSelectWidget(_ widget: Widget) {
		widget.action?.run()
	}
	
	func applicationDidBecomeActive() {
		self.viewDidLoad()
	}
	
}
