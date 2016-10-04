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
	func showWidgets(widgets: [Widget])
	func getWidth() -> Int
}


class WidgetListPresenter {
	
	private var view: WidgetListView
	private lazy var widgetListInteractor = WidgetListInteractor(
		service: WidgetListService(),
		storage: Storage.shared
	)
	
	
	init(view: WidgetListView) {
		self.view = view
	}
	
	func viewDidLoad() {
		self.widgetListInteractor.widgetList(maxWidth: self.view.getWidth(), minWidth: self.view.getWidth() / 2) { result in
			switch result {
			case .Success(let widgets):
				self.view.showWidgets(widgets)
				
			case .Empty:
				LogInfo("Empty")
				self.view.showEmptyError()
				
			case .Error:
				LogInfo("Error")
			}
		}
	}
	
	func userDidSelectWidget(widget: Widget) {
		widget.action?.run()
	}
	
	func applicationDidBecomeActive() {
		self.viewDidLoad()
	}
	
}
