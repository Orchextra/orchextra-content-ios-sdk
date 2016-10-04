//
//  WidgetListVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class WidgetListVC: UIViewController {
	
	@IBOutlet weak var pageControl: UIPageControl!
	
	var presenter: WidgetListPresenter!
	
	private var widgets: [Widget] = []
	
	// MARK: - UI Properties
	@IBOutlet weak private var collectionView: UICollectionView!
	@IBOutlet weak private var viewNoContent: UIView!
	@IBOutlet weak private var imageNoContent: UIImageView!
	@IBOutlet weak private var labelNoContent: UILabel!
	@IBOutlet weak private var labelComeBack: UILabel!
	
	
	// MARK - View's Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupView()
		
		self.presenter.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserverForName(
			UIApplicationDidBecomeActiveNotification,
			object: nil,
			queue: nil) { _ in
				self.presenter.applicationDidBecomeActive()
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.collectionView.reloadData()
	}
	
	
	// MARK: - Private Helpers
	
	private func setupView() {
		self.imageNoContent.image = Config.noContentImage
		self.viewNoContent.hidden = true
		
		self.labelNoContent.text = kLocaleCouponsCampaignsEmpty
		self.labelComeBack.text = kLocaleCouponsCampaignsEmptyComeBack
	}
	
	private func showPageControlWithPages(pages: Int) {
		self.pageControl.numberOfPages = pages
	}
	
}


// MARK: - Presenter

extension WidgetListVC: WidgetListView {
	
	func showWidgets(widgets: [Widget]) {
		self.widgets = widgets
		self.showPageControlWithPages(self.widgets.count)
		self.collectionView.hidden = false
		self.viewNoContent.hidden = true
		self.collectionView.reloadData()
	}
	
	func getWidth() -> Int {
		return Int(self.view.width() * UIScreen.mainScreen().scale)
	}
	
	func showEmptyError() {
		self.collectionView.hidden = true
		self.viewNoContent.hidden = false
	}
}


// MARK: - CollectionViewDataSource

extension WidgetListVC: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.widgets.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! WidgetCell
		
		cell.bindWidget(self.widgets[indexPath.row])
		
		return cell
	}
	
	// MARK: - ScrollView Delegate
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
		self.pageControl.currentPage = Int(currentIndex)
	}
}


// MARK: - CollectionViewDelegate

extension WidgetListVC: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard indexPath.row < self.widgets.count else {
			return LogWarn("Index out of range")
		}
		
		let widget = self.widgets[indexPath.row]
		self.presenter.userDidSelectWidget(widget)
	}
	
}


// MARK: - UICollectionViewDelegateFlowLayout

extension WidgetListVC: UICollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return collectionView.size()
	}
	
}
