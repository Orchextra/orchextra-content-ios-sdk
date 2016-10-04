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
	
	fileprivate var widgets: [Widget] = []
	
	// MARK: - UI Properties
	@IBOutlet weak fileprivate var collectionView: UICollectionView!
	@IBOutlet weak fileprivate var viewNoContent: UIView!
	@IBOutlet weak fileprivate var imageNoContent: UIImageView!
	@IBOutlet weak fileprivate var labelNoContent: UILabel!
	@IBOutlet weak fileprivate var labelComeBack: UILabel!
	
	
	// MARK - View's Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupView()
		
		self.presenter.viewDidLoad()
		
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil,
			queue: nil) { _ in
				self.presenter.applicationDidBecomeActive()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.collectionView.reloadData()
	}
	
	
	// MARK: - Private Helpers
	
	fileprivate func setupView() {
		self.imageNoContent.image = Config.noContentImage
		self.viewNoContent.isHidden = true
		
		self.labelNoContent.text = kLocaleCouponsCampaignsEmpty
		self.labelComeBack.text = kLocaleCouponsCampaignsEmptyComeBack
	}
	
	fileprivate func showPageControlWithPages(_ pages: Int) {
		self.pageControl.numberOfPages = pages
	}
	
}


// MARK: - Presenter

extension WidgetListVC: WidgetListView {
	
	func showWidgets(_ widgets: [Widget]) {
		self.widgets = widgets
		self.showPageControlWithPages(self.widgets.count)
		self.collectionView.isHidden = false
		self.viewNoContent.isHidden = true
		self.collectionView.reloadData()
	}
	
	func getWidth() -> Int {
		return Int(self.view.width() * UIScreen.main.scale)
	}
	
	func showEmptyError() {
		self.collectionView.isHidden = true
		self.viewNoContent.isHidden = false
	}
}


// MARK: - CollectionViewDataSource

extension WidgetListVC: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.widgets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WidgetCell
		
		cell.bindWidget(self.widgets[(indexPath as NSIndexPath).row])
		
		return cell
	}
	
	// MARK: - ScrollView Delegate
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
		self.pageControl.currentPage = Int(currentIndex)
	}
}


// MARK: - CollectionViewDelegate

extension WidgetListVC: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard (indexPath as NSIndexPath).row < self.widgets.count else {
			return LogWarn("Index out of range")
		}
		
		let widget = self.widgets[(indexPath as NSIndexPath).row]
		self.presenter.userDidSelectWidget(widget)
	}
	
}


// MARK: - UICollectionViewDelegateFlowLayout

extension WidgetListVC: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return collectionView.size()
	}
	
}
