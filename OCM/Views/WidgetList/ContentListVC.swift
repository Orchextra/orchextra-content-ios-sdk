//
//  ContentListVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ContentListVC: UIViewController {
	
	@IBOutlet weak var pageControl: UIPageControl!
	
	var presenter: ContentListPresenter!
    
    fileprivate var layout: Layout?
    
	fileprivate var contents: [Content] = []
	
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
        
        self.navigationController?.navigationBar.isTranslucent = false
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil,
			queue: nil) { _ in
				self.presenter.applicationDidBecomeActive()
		}
	}
    
    func layout(_ layout: Layout) {
        
        self.layout = layout
        
        var newLayout: UICollectionViewLayout
        
        switch layout {
        case .carousel:
            newLayout = CarouselFlowLayout()
            
        case .mosaic:
            let mosaicLayout = MosaicFlowLayout()
            mosaicLayout.delegate = self
            newLayout = mosaicLayout
        }
        collectionView.collectionViewLayout = newLayout
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

extension ContentListVC: ContentListView {
	
	func showContents(_ contents: [Content]) {
		self.contents = contents
		self.showPageControlWithPages(self.contents.count)
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

extension ContentListVC: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.contents.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ContentCell
		
		cell.bindContent(self.contents[(indexPath as NSIndexPath).row])
		
		return cell
	}
	
	// MARK: - ScrollView Delegate
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
		self.pageControl.currentPage = Int(currentIndex)
	}
}


// MARK: - CollectionViewDelegate

extension ContentListVC: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard (indexPath as NSIndexPath).row < self.contents.count else {
			return LogWarn("Index out of range")
		}
		
		let content = self.contents[(indexPath as NSIndexPath).row]
		self.presenter.userDidSelectContent(content)
	}
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ContentListVC: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.layout == .mosaic {
            return CGSize(width: 1, height: 1)
        } else {
            return collectionView.size()
        }
	}
	
}
